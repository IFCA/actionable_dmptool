class TaxonomiesController < ApplicationController
  before_action :require_login
  before_action :set_taxonomy, only: [:show, :edit, :update, :destroy]

  # Aqui entra cuando se le da al enlace para entrar en /taxonomies
  def index
    load_taxonomies
  end

  def show
    @taxonomy_name = @taxonomy.name
    @conceptTree = get_concept_tree
  end

  # GET /taxonomies/edit => Carga la taxonomia en el objeto para editar
  def edit
  end

  def set_taxonomy
    @taxonomy = Taxonomy.find(params[:id])
  end

  # Se entra al pulsar el boton crear nueva taxonomia
  def dmp_for_taxonomy
    @taxonomy = Taxonomy.new

    @back_to = taxonomies_path
    @back_text = "Previous page"
    @submit_to = new_taxonomy_path
    @submit_text = "Next page"
  end

  # Metodo privado que se llama al entrar en las taxonomias y buscar el listado de taxonomias
  def load_taxonomies
    #@taxonomies = Taxonomy.paginate(:all, :order => "name")

    @scope = params[:scope]
    @order_scope = params[:order_scope]

    case @order_scope
      when "Name"
        @taxonomies = Taxonomy.order(:name)
      when "Description"
        @taxonomies = Taxonomy.order(:description)
      when "URL"
        @taxonomies = Taxonomy.order(:url)
      when "Namespace"
        @taxonomies = Taxonomy.order(:namespace)
      when "PrefLabel"
        @taxonomies = Taxonomy.order(:prefLabel)
      when "Property"
        @taxonomies = Taxonomy.order(:property)
      when "Creation_Date"
        @taxonomies = Taxonomy.order(:created_at)
      when "Last_Modification_Date"
        @taxonomies = Taxonomy.order(:updated_at)
      else
        @taxonomies = Taxonomy.order(:name)
    end

    case @scope
      when "all"
        @taxonomies = @taxonomies.page(params[:page]).per(1000)
      else
        @taxonomies = @taxonomies.page(params[:page]).per(10)
    end

  end

  #Eliminar una taxonomia
  def destroy

    @taxonomy.destroy

    Viaconcept.where(:taxonomy => @taxonomy.name).destroy_all

    @taxonomies = Taxonomy.find(:all, :order => "name")


    respond_to do |format|
      format.html { redirect_to taxonomies_url }
      format.json { head :no_content }
    end
  end

  # Guardar una nueva taxonomia
  def create

    pare_to = ['name','description','url', 'namespace', 'prefLabel', 'property']
    @taxonomy = Taxonomy.new(params['taxonomy'].selected_items(pare_to))


    message = @taxonomy.changed ? 'Taxonomy was successfully created.' : ''

    # Si ha cargado la URL guardamos todos los conceptos asociados
    if !@taxonomy.url.blank?
      begin
        load_concepts
      rescue Errno::ENOENT
        message = 'The taxonomy was successfully created, but there is no valid RDF at this URL'
        @taxonomy.url = ''
      end

    end

    respond_to do |format|
      if @taxonomy.save
        go_to = (params[:after_save] == 'next_page' ? taxonomy_path(@taxonomy.id) :
            edit_taxonomy_path(@taxonomy.id))
        format.html { redirect_to go_to, notice: message }
        format.json { head :no_content }
      else
        format.html { render 'new'}
        format.json { head :no_content }

      end
    end

  end


  # Actualiza la taxonomia
  def update

    old_url = @taxonomy.url
    pare_to = ['name','description','url', 'namespace', 'prefLabel', 'property']

    to_save = params['taxonomy'].selected_items(pare_to)
    message = @taxonomy.changed ? 'Taxonomy was successfully updated.' : ''

    if(params['commit']=='Upload')
      to_save['name'] = @taxonomy.name
      to_save['description'] = @taxonomy.description
      to_save['namespace'] = @taxonomy.namespace
      to_save['prefLabel'] = to_save['prefLabel'].tempfile.path
      to_save['property'] = to_save['property'].tempfile.path
      to_save['url'] = to_save['url'].tempfile.path
    end


    go_to = (params[:after_save] == 'next_page' ? taxonomies_path(@taxonomy.id) : edit_taxonomy_path(@taxonomy.id) )

    respond_to do |format|
    if @taxonomy.update(to_save)
      if !@taxonomy.url.blank? and @taxonomy.url != old_url
        begin
          load_concepts
        rescue Errno::ENOENT
          message = 'Taxonomy was successfully updated, but there is no valid RDF at this URL or File'
        end
      end

      format.html { redirect_to go_to, notice: message }
      format.json { head :no_content }
    else
      format.html { render 'edit'}
      format.json { head :no_content }

    end
  end

end



  def get_concept_tree
    roots = Viaconcept.where("taxonomy='#{@taxonomy_name}' and parent is null")
    aux = Viaconcept.where("taxonomy='#{@taxonomy_name}' ")
    parents = parent_map aux
    listAux = Array.new
    roots.each do |root|
      mapAux = Hash.new
      mapAux[:id]=root.identifier
      mapAux[:label]=root.label
      listAux.push mapAux
    end
    to_tree(listAux, parents)
  end

  def to_tree (list, parents)
    map = Array.new
    list.each do |root|
      id = root[:id]
      mapAux = Hash.new
      mapAux[:label]=root[:label]
      mapAux[:children] = to_tree(parents[id], parents) unless parents[id].nil?
      map.push mapAux
    end
    return map

  end

  def parent_map (list)
    map = Hash.new
    list.each do |element|
      if(map[element.parent].nil?)
        listAux = Array.new
      else
        listAux = map[element.parent]
      end
      mapAux = Hash.new
      mapAux[:id]=element.identifier
      mapAux[:label]=element.label
      listAux.push mapAux
      map[element.parent] = listAux
    end
    return map
  end


  # METODOS DE CARGA DE CONCEPTOS ASOCIADOS A LA TAXONOMIA
  def load_concepts
    graph = RDF::Graph.load(@taxonomy.url)
    # cargamos el RDF en un mapa
    map = to_map3 graph

    if map.blank?
      map = to_map3 graph
    end

    #Vaciamos la tabla asociada a la taxonomia
    Viaconcept.where(:taxonomy => @taxonomy.name).destroy_all
    #Recorremos el listado de conceptos resultantes de la query. El id y parent son URLS
    map.each do |key, map|
      concept = Viaconcept.new
      concept.identifier = key
      concept.label = map[:label]
      concept.description = map[:description]
      concept.parent = map[:parent]
      concept.taxonomy = @taxonomy.name
      concept.save
      #puts "#{element.concept.path.split('/').last} label=#{element.label} description=#{} parent=#{element.parent.path.split('/').last}"
    end
  end

  def to_map (graph)
    #Query para separar cada uno de los conceptos
    logger.error("Fer was here")
    query = RDF::Query.new({:aux => {RDF.type  => RDF::SKOS.Concept,
                                     RDF::SKOS.prefLabel => :label}})
    map = Hash.new
    query.execute(graph) do |element|
      mapAux = Hash.new
      id = element.aux.to_s
      label = element.label.to_s
      mapAux[:id]=id
      mapAux[:label]=label
      map[id] = mapAux
    end


    #Query para obtener los padres
    query = RDF::Query.new({
                               :concept => {
                                   RDF.type  => RDF::SKOS.Concept,
                                   RDF::SKOS.broader => :parent
                               }
                           })
    #Recorremos el listado de conceptos resultantes de la query. El id y parent son URIS y hay que tratarlas
    query.execute(graph) do |element|
      id = element.concept.to_s
      parent = element.parent.to_s
      mapAux = map[id][:parent] = parent
    end

    #Query para obtener las definiciones
    query = RDF::Query.new({
                               :concept => {
                                   RDF.type  => RDF::SKOS.Concept,
                                   RDF::SKOS.definition => :description
                               }
                           })
    #Recorremos el listado de conceptos resultantes de la query. El id y parent son URIS y hay que tratarlas
    query.execute(graph) do |element|
      id = element.concept.to_s
      description = element.description.to_s
      mapAux = map[id][:description] = description
    end
    return map
  end


  def to_map2 (graph)
    #Query para separar cada uno de los conceptos
    query = RDF::Query.new({:aux => { RDF::FOAF.name => :label}})
    map = Hash.new
    query.execute(graph) do |element|
      mapAux = Hash.new
      id = element.aux.to_s
      label = element.label.to_s
      logger.error("Fer label #{label}")
      logger.error("Fer NAMESPACE #{@taxonomy.namespace}")
      mapAux[:id]=id
      mapAux[:label]=label
      mapAux[:description]=label
      map[id] = mapAux
    end

    return map
  end

  def to_map3 (graph)
    logger.error("entro EN MAP 3")
    #Get the URL introduced by the user
    map = Hash.new

    logger.error("Fer prefLabel? #{@taxonomy.prefLabel}")
    logger.error("Fer property? #{@taxonomy.property}")
    logger.error("Fer description? #{@taxonomy.description}")
    logger.error("Fer parent? #{@taxonomy.namespace}")

    #Query for getting ID and label
    query = RDF::Query.new({
      :object => {
         RDF::URI(@taxonomy.prefLabel) => :name,
         RDF::URI(@taxonomy.property) => :id
      }
    })

    query.execute(graph) do |element|
      logger.error("Fer Element\n")
      mapAux = Hash.new
      id = element.object.to_s
      label = element.name.to_s
      logger.error("Fer label #{label}\n")
      logger.error("Fer ID #{id}\n")
      logger.error("Fer----------------\n")
      mapAux[:id]=id
      mapAux[:label]=label
      map[id] = mapAux

    end

    #Query for getting parent
    query = RDF::Query.new({
      :object => {
         RDF::URI(@taxonomy.property) => :id,
         RDF::URI(@taxonomy.namespace) => :parent
      }
    })

    query.execute(graph) do |element|
      logger.error("Fer Element\n")
      mapAux = Hash.new
      id = element.object.to_s
      parent = element.parent.to_s
      logger.error("Fer Parent #{parent}\n")
      logger.error("Fer ID #{id}\n")
      logger.error("Fer----------------\n")
      mapAux = map[id][:parent] = parent

    end

    #Query for getting description
    query = RDF::Query.new({
      :object => {
         RDF::URI(@taxonomy.property) => :id,
         RDF::URI(@taxonomy.description) => :description
      }
    })

    query.execute(graph) do |element|
      logger.error("Fer Element\n")
      mapAux = Hash.new
      id = element.object.to_s
      description = element.description.to_s
      logger.error("Fer ID #{id}\n")
      logger.error("Fer desc: #{description}")
      logger.error("Fer----------------\n")
      mapAux = map[id][:description] = description

    end


    return map 

  end


end






