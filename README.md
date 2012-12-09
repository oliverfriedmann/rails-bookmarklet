rails-bookmarklet
=================

A bookmarklet gem for rails.


## Installation

1.  Add this to your Gemfile: ```gem "rails-bookmarklet", :git => "https://github.com/oliverfriedmann/rails-bookmarklet.git"```

2.  Run ```bundle install```


## Bookmarklet Link

The bookmarklet will be launched by a special bookmark in the user's browser.
The bookmark's link is javascript code that loads a remote script into the context of the current page.
The javascript code for the bookmark is generated as follows:

  ```ruby
    RailsBookmarklet::compile_invocation_script(
      url,
      options
    )
  ```

The url has to be given as absolute path to your action handling the transmission of the remote script that should be loaded when the user clicks on the bookmarklet.
If you want to be able to identify your user by a token, url could be given as follows:

  ```ruby
    mybookmarklet_url(:only_path => false, :token => current_user.token)
  ```
    
The optional options hash allows two parameters:

- ```:error_message```: a string message that is shown to the user in the browser in case something goes wrong, and
- ```:params```: a hash of key/values-pairs that should be added to the url.

The bookmarklet script provides two variables, ```d = document``` and ```b = d.body```, that can be used in the params hash, e.g. you could add the following parameters to transmit the browser's date and the document's title to your server:

  ```ruby
    :params => {"time" => "'+(new Date().getTime())+'",
                "title" => "'+encodeURIComponent(d.title)+'"}
  ```


## Bookmarklet Controller

In the controller that handles the ```mybookmarklet``` action, you need to ```include RailsBookmarklet```.
In the action, you could (as an example) log the browser's request to your database and then render the remote script for the bookmarklet:

  ```ruby
    def show
      @uri = request.env["HTTP_REFERER"]
      @title = params[:title]
      @time = Time.new
      @token = params[:token]
      @bookmarklet_user = User.find_by_token(@token)
      @request = MyBookmarkletRequest.create(
                        :user_id => @bookmarklet_user.id,
                        :uri => @uri,
                        :title => @title,
                        :time => @time)      
      render_bookmarklet("mybookmarklet", "show")
    end
  ```
    
The ```render_bookmarklet(namespace, view, options = {})``` function takes the following arguments:
- ```namespace```: a string that namespaces an invisible html container that is automatically created in the browser's context,
- ```view```: the name of your view that should be rendered in the context of the invisible html container, and
- ```options```: the options for rendering the view.


## Bookmarklet View

An example view could look as follows:

  ```html
  	<style id="bookmarklet_style">
		.mybookmarklet_htmlbase {
		  position: fixed;
		  z-index: 2147483646;
		  left: 0pt;
		  top: 0pt;
		  width: 100%;
		  height: 100%;
		  opacity: 0.9;
		  padding: 141px 0pt 0pt;
		  margin: 0pt;
		  background-color: rgb(0, 0, 0);
		}
		
		.mybookmarklet_htmlcontent {
		  position: fixed;
		  top: 10px;
		  left: 50%;
		  z-index: 2147483647;
		  width: 400px;
		  margin-left: -200px;
		  background-color: rgb(255, 255, 240);
		  -moz-border-radius: 15px;
		  border-radius: 15px;
		  border-style: dotted;
		  border-color: rgb(127, 127, 127);
		  padding: 15px;
		}
		</style>
		
		<div id="mybookmarklet_htmlbase" class="mybookmarklet_htmlbase" onclick="mybookmarklet_content_unload()">
		</div>
		
		<div id="mybookmarklet_htmlcontent" class="mybookmarklet_htmlcontent">
			Hello World!
		</div>
		
		<script language="JavaScript">
			function mybookmarklet_content_unload() {
				document.body.removeChild(document.getElementById('mybookmarklet_htmlcontent'));
				document.body.removeChild(document.getElementById('mybookmarklet_htmlbase'));
				mybookmarklet_unload();
			}
			
			function mybookmarklet_content_load() {
				document.body.appendChild(document.getElementById("mybookmarklet_htmlcontent"));
				document.body.appendChild(document.getElementById("mybookmarklet_htmlbase"));
			}
			
			function mybookmarklet_token() {
				return '<%= @token %>';
			}
			
			mybookmarklet_content_load();
		</script>
  ```
    
When this view is loaded into the context of the user's browser, the two divs are added to visible area of the user's browser.
You can then load more scripts etc. by AJAX calls as you would normally do.