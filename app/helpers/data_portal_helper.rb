module DataPortalHelper
        def submit_dmp_dataportal(plan)
                base_url = APP_CONFIG['data_portal_base_url']
                access_token = APP_CONFIG['data_portal_token']
                plan_id = plan.id
                uri = URI.parse("#{base_url}")
                title = "DMPTool: DMP #{Time.now.inspect}"
                description = "Description of the Current DMP #{Time.now.inspect}"
                creators = @plan.owner['last_name'] + ", " + @plan.owner['first_name']
                affiliation = "IFCA" #TODO
                keywords = "Cuerda del Pozo, Reservoir, Fresh Water" #TODO
                project = "2" #TODO

                data = '{"metadata": {"title": "' + title + '", "upload_type": "dmp","description": "' + description + '","creators": [{"name": "' + creators + '","affiliation": "' + affiliation + '"}],"keywords": {"Keyword 1": "test","Keyword 2": "test2"}, "project": "' + project + '"}}'

                json = JSON.parse(data)
                puts data
                create_path = "/api/deposit/depositions/" #TODO
                uri = URI.parse("#{base_url}#{create_path}?access_token=#{access_token}")
                puts "POST to URI: #{uri}"
                response = ""
                logger.error("POST DMP [#{title}] to DataPortal:< #{create_path}?access_token=#{access_token}")
                req = Net::HTTP::Post.new("#{create_path}?access_token=#{access_token}", initheader = {'Content-Type' =>'application/json'})
                req.body = json.to_json
                res = Net::HTTP.start(uri.hostname, uri.port,
                  :use_ssl => uri.scheme == 'https') do |http|
                  response = http.request(req)
                end

                json = JSON.parse(response.body)
                deposition_id = json['id']
                return deposition_id
        end
        def send_file_dataportal(data,deposition_id)
            base_url = APP_CONFIG['data_portal_base_url']
            access_token = APP_CONFIG['data_portal_token']
            upload_path = "/api/deposit/depositions/#{deposition_id}/files/"
            uri = URI.parse("#{base_url}#{upload_path}?access_token=#{access_token}")
            headers = {"Content-Type" => "multipart/form-data"}
            logger.error("POST FILE to DataPortal: #{upload_path}?access_token=#{access_token}")
            
            begin
              file = File.open("./tmp/cache/dmp.rdf", "w")
              file.write(data) 
            rescue IOError => e
              #some error occur, dir not writable etc.
              logger.error("Error writting file")
            ensure
              file.close unless file.nil?
            end
            file = File.new("./tmp/cache/dmp.rdf", 'r+')
            req = Net::HTTP::Post::Multipart.new upload_path + "?access_token=#{access_token}",
              "file" => UploadIO.new(file, "application/octet-stream", "dmp.rdf", :use_ssl => uri.scheme == 'https')
            Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
              response = http.request(req)
            end
            File.delete("./tmp/cache/dmp.rdf")

            #TODO Manage answer json
         end

         def publish_dmp_dataportal(deposition_id)
             base_url = APP_CONFIG['data_portal_base_url']
             access_token = APP_CONFIG['data_portal_token']
             publish_path = "/api/deposit/depositions/#{deposition_id}/actions/publish"
             uri = URI.parse("#{base_url}#{publish_path}?access_token=#{access_token}")
             logger.error("POST Publish DataPortal:< #{publish_path}?access_token=#{access_token}")
             req = Net::HTTP::Post.new("#{publish_path}?access_token=#{access_token}", initheader = {'Content-Type' =>'application/json'})
             Net::HTTP.start(uri.hostname, uri.port,:use_ssl => uri.scheme == 'https') do |http|
               response = http.request(req)
             end
#             json = JSON.parse(response.body)
 #            logger.error(json)
                 #response = http.request(req)
             
             #TODO manage answer json
         end

end
