module UserLdap
  class Server

    include LdapMixin

    def find_all
      return @admin_ldap.search(:base => @base,
                                :filter => (Net::LDAP::Filter.eq('objectclass', 'inetOrgPerson') &
                                    Net::LDAP::Filter.eq('objectclass', 'dmpUser')),
                                :scope => Net::LDAP::SearchScope_SingleLevel).
          sort_by{ |user| user['cn'][0].downcase }
    end

    def add(login_id, password, first_name, last_name, email)
      attr = {
          :objectclass           => ["top", "inetOrgPerson", 'person'],
          :uid                   => login_id,
          :sn                    => last_name,
          :givenName             => first_name,
          :cn                    => "login_id",
          :displayName           => "#{first_name} #{last_name}",
          :userPassword          => password,
          #:arkId                 => "#{@minter.mint_erc(ns_dn(login_id), 'DMP User', Time.new.to_s)}",
          :mail                  => email
      }
      true_or_exception(@admin_ldap.add(:dn => ns_dn(login_id), :attributes => attr))
    end

    def authenticate(login_id, password)
      raise LdapException.new('user does not exist') if !record_exists?(login_id)
      @admin_ldap.bind_as(:base => @base, :filter => Net::LDAP::Filter.eq('uid', login_id), :password => password)
    end

    def change_password(user_dn, password)
      result = replace_attribute_dn(user_dn, :userPassword, password)
      true_or_exception(result)
    end

    def ns_dn(id)
      "cn=#{id},#{@base}"
    end

    def obj_filter(id)
      Net::LDAP::Filter.eq("uid", id)
    end
  end
end
