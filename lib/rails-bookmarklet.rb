module RailsBookmarklet
  
    require 'rails-bookmarklet/engine'

    def self.compile_invocation_script(url, options = {})
        default_error_message = "Something went wrong with the bookmarklet."
        error_message = options.has_key?(:error_message) ? options[:error_message] : default_error_message

        full_url = url
        if options.has_key?(:params)
          options[:params].each do |key,value|
            if !((full_url.ends_with? "?") || (full_url.ends_with? "&"))
              full_url += (full_url.include? "?") ? "&" : "?" 
            end
            full_url += key + "=" + value
          end
        end

        return "javascript:(function(){var d=document,z=d.createElement('scr'+'ipt'),b=d.body;try{" +
               "if(!b)throw(0);z.setAttribute('src','" + full_url + "');b.appendChild(z);}" + 
               "catch(e){alert('" + error_message + "');}}).call(this);"
    end
    
    def render_bookmarklet(namespace, view, options = {})
      options[:layout] = false
      raw_html = render_to_string view, options
  
      tags = []
  
      document = HTML::Document.new(raw_html)
      document.root.children.each do |child|
        if child.tag?
          innerHTML = "";
          child.children.each { |child_child| innerHTML << child_child.to_s }
          tags.push({
            :name => child.name,
            :attributes => child.attributes,
            :innerHTML => innerHTML
          });
        end
      end
      
      render 'bookmarklet/bookmarklet', :layout => false, :locals => {:namespace => namespace, :tags => tags}
    end
    
    def self.important_stylesheet(path)
      return Rails.application.class.assets.find_asset(path).body.gsub(";", " !important;")
    end
    
    def self.namespace_javascript(path, base, variable)
      s =
        "(function () {\n" +
          Rails.application.class.assets.find_asset(path).body + "\n" +
          base + "." + variable + " = " + variable + ";\n" +
        "}).call(this);\n"
      return s
    end
    
    def bookmarklet_stylesheet_link_tag(source, options = {})
      old = ActionController::Base.asset_host
      ActionController::Base.asset_host = request.host_with_port
      s = stylesheet_link_tag(source, options)
      ActionController::Base.asset_host = old
      return s
    end
    
    def bookmarklet_asset_url(source)
      return root_url(:only_path => false) + "assets/" + source
    end

    def bookmarklet_javascript_include_tag(source, options = {})
      old = ActionController::Base.asset_host
      ActionController::Base.asset_host = request.host_with_port
      s = javascript_include_tag(source, options)
      ActionController::Base.asset_host = old
      return s
    end

end
