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

In the controller that handles the ```mybookmarklet``` action, you need to include the controller's helper, and in the helper add ```include RailsBookmarklet```.
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
		
		<div id="mybookmarklet_htmlbase" class="mybookmarklet_htmlbase" onclick="mybookmarklet.base.content_unload()">
		</div>
		
		<div id="mybookmarklet_htmlcontent" class="mybookmarklet_htmlcontent">
			Hello World!
		</div>
		
		<script language="JavaScript">
			mybookmarklet.base = {};
		
			mybookmarklet.base.content_unload = function () {
				document.body.removeChild(document.getElementById('mybookmarklet_htmlcontent'));
				document.body.removeChild(document.getElementById('mybookmarklet_htmlbase'));
				mybookmarklet.bookmarklet.unload();
			}
			
			mybookmarklet.base.content_load = function () {
				document.body.appendChild(document.getElementById("mybookmarklet_htmlcontent"));
				document.body.appendChild(document.getElementById("mybookmarklet_htmlbase"));
			}
			
			mybookmarklet.base.token = function () {
				return '<%= @token %>';
			}
			
			mybookmarklet.base.content_load();
		</script>
  ```
    
When this view is loaded into the context of the user's browser, the two divs are added to visible area of the user's browser.
You can then load more scripts etc. by AJAX calls as you would normally do.


## Stylesheets

There are two issues with stylesheets that you use in your bookmarklet:

- namespacing: you need to make sure that your style classes do not collide with already existing style classes of the host site and
- resetting: you need to make sure that all styles imposed by the host site are reset for your html.

In order to reset the styles of the host site, we include the namespaced reset stylesheet <a href="https://github.com/premasagar/cleanslate">cleanslate</a>.

Next, we will namespace our existing stylesheets using the asset pipeline and scss. The cleanslate stylesheet sets all style properties with the !important tag, so we need to make sure that our custom stylesheets use the !improtant tag for their properties as well.
A convenience routine that automatically adds !important to each style property has been added to the Gem.

Instead of adding the stylesheet directly to your view, you can add it as link:

  ```ruby
    <%= bookmarklet_stylesheet_link_tag "mybookmarklet" %>
  ```
  
Create a new file ```mybookmarklet.css.scss.erb``` in your stylesheets asset folder and the following lines (as an example, we will use <a href="https://github.com/anjlab/bootstrap-rails">twitter-bootstrap</a>):

  ```css
	@import 'cleanslate';
	
	.mybookmarklet {
	  <%= RailsBookmarklet::important_stylesheet("bootstrap.css") %>
	  <%= RailsBookmarklet::important_stylesheet("responsive.css") %>
	  <%= RailsBookmarklet::important_stylesheet("mybookmarklet/style") %>
	}
	
	<%= RailsBookmarklet::important_stylesheet("mybookmarklet/base") %>
  ```
  
First, we include the cleanslate reset (which is namespaced by "cleanslate"). Second, we namespace twitter-bootstrap and our own style file by "mybookmarklet". We use the convenience method ```RailsBookmarklet::important_stylesheet``` to make all properties important. Finally, we include our base style (which should be used to style your outermost container).

Your view's content container should then look as follows:

  ```html
	<div id="mybookmarklet_htmlcontent" class="cleanslate mybookmarklet mybookmarklet-base">
		Hello World!
	</div>
  ```


## JavaScripts

You can either load javascript files like stylesheets by the convenience method ```bookmarklet_javascript_include_tag``` or load via your own code as follows:

  ```javascript
  	mybookmarklet.support.load_script("<%= bookmarklet_asset_url "mybookmarklet.js" %>", function() {
  		alert("Yikes, the script has been loaded!");
  	});
  ```
  
As with the stylesheets, you need to make sure that your javascript code is namespaced. There is no automatic support included in this Gem to namespace javascript code (note that this is probably not even possible in general due to the halting problem etc.).
You can namespace ```jQuery``` as follows:

  ```javascript
	//= require jquery
	mybookmarklet.$ = jQuery.noConflict(true);
  ```
