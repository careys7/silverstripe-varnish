#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and https://www.varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Adapted from https://raw.githubusercontent.com/xini/silverstripe-section-io/master/default.vcl

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "127.0.0.1";
    .port = "8080";
}

acl purge {
  "localhost";
  "127.0.0.1";
}

sub vcl_recv {
	# Happens before we check if we have this in cache already.
	#
	# Typically you clean up the request here, removing cookies you don't need,
	# rewriting the request, etc.

	# clean up accept-encoding
	if (req.http.Accept-Encoding) {
		if (req.http.Accept-Encoding ~ "gzip") {
			set req.http.Accept-Encoding = "gzip";
		} else if (req.http.Accept-Encoding ~ "deflate") {
			set req.http.Accept-Encoding = "deflate";
		} else {
			unset req.http.Accept-Encoding;
		}
	}

    # Purge Request
    if (req.method == "PURGE") {
        if (!client.ip ~ purge) {
            return (synth(405, "Not allowed."));
        }
        ban("obj.http.x-purge-url ~ " + req.http.X-Purge-Url-Regex);
        return (synth(200, "Purged"));
    }

	# remove cookies for static content based on /assets/.htaccess
	if (req.url ~ ".*\.(?:js|css|bmp|png|gif|jpg|jpeg|ico|pcx|tif|tiff|au|mid|midi|mpa|mp3|ogg|m4a|ra|wma|wav|cda|avi|mpg|mpeg|asf|wmv|m4v|mov|mkv|mp4|ogv|webm|swf|flv|ram|rm|doc|docx|txt|rtf|xls|xlsx|pages|ppt|pptx|pps|csv|cab|arj|tar|zip|zipx|sit|sitx|gz|tgz|bz2|ace|arc|pkg|dmg|hqx|jar|pdf|woff|eot|ttf|otf|svg)(?=\?|&|$)") {
		unset req.http.Cookie;
		return (hash);
	}

	# ss admin
	if (req.url ~ "^/(Security|admin|dev)" || req.url ~ "stage=") {
		return (pass);
	}

	# ss multistep form
	if( req.url ~ "MultiFormSessionID=" ) {
		return (pass);
	}

	# check for login cookie
	if ( req.http.Cookie ~ "sslogin=" ) {
		return (pass);
	}

	# remove tracking cookies
	if (req.http.Cookie) {
		set req.http.Cookie = regsuball(req.http.Cookie, "(^|(?<=; )) *__utm.=[^;]+;? *", "\1"); # standard ga cookies
		set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(_dc_gtm_[A-Z0-9\-]+)=[^;]*", ""); # gtm cookies
		set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(_ga)=[^;]*", ""); # gtm ga cookies
		set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(_gat)=[^;]*", ""); # legacy ga cookies
		set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(AUA[0-9]+)=[^;]*", ""); # avanser phone tracking cookies
		set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(sc_is_visitor_unique)=[^;]*", ""); # StatCounter web analytics

		if (req.http.Cookie == "") {
			unset req.http.Cookie;
		}
	}

	# remove adwords gclid parameter
	set req.url = regsuball(req.url,"\?gclid=[^&]+$",""); # strips when QS = "?gclid=AAA"
	set req.url = regsuball(req.url,"\?gclid=[^&]+&","?"); # strips when QS = "?gclid=AAA&foo=bar"
	set req.url = regsuball(req.url,"&gclid=[^&]+",""); # strips when QS = "?foo=bar&gclid=AAA" or QS = "?foo=bar&gclid=AAA&bar=baz"
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.

    # Set ban-lurker friendly url for purge
    set beresp.http.X-Purge-URL  = bereq.url;

    if (bereq.url ~ ".*\.(?:css|js)(?=\?|&|$)") {
        set beresp.ttl = 604800s; # The number of seconds to cache inside Varnish: 1 week
        set beresp.http.Cache-Control = "public, max-age=604800"; # The number of seconds to cache in browser: 1 week
    }
    # images, audio, video
    if (bereq.url ~ ".*\.(?:bmp|png|gif|jpg|jpeg|ico|pcx|tif|tiff|au|mid|midi|mpa|mp3|ogg|m4a|ra|wma|wav|cda|avi|mpg|mpeg|asf|wmv|m4v|mov|mkv|mp4|ogv|webm|swf|flv|ram|rm)(?=\?|&|$)") {
        set beresp.ttl = 2592000s; # The number of seconds to cache inside Varnish: 1 month
        set beresp.http.Cache-Control = "public, max-age=2592000"; # The number of seconds to cache in browser: 1 month
    }
    # docs and archives
    if (bereq.url ~ ".*\.(?:doc|docx|txt|rtf|xls|xlsx|pages|ppt|pptx|pps|csv|cab|arj|tar|zip|zipx|sit|sitx|gz|tgz|bz2|ace|arc|pkg|dmg|hqx|jar|pdf)(?=\?|&|$)") {
        set beresp.ttl = 2592000s; # The number of seconds to cache inside Varnish: 1 month
        set beresp.http.Cache-Control = "public, max-age=2592000"; # The number of seconds to cache in browser: 1 month
    }
    # fonts
    if (bereq.url ~ ".*\.(?:woff|eot|ttf|otf|svg)(?=\?|&|$)") {
        set beresp.ttl = 2592000s; # The number of seconds to cache inside Varnish: 1 month
        set beresp.http.Cache-Control = "public, max-age=2592000"; # The number of seconds to cache in browser: 1 month
    }
    # set cache control header for pages
    if (beresp.http.Content-Type ~ "^text/html" && !(bereq.url ~ "^/(Security|admin|dev)") && !(bereq.http.Cookie ~ "sslogin=") && !(beresp.http.Pragma ~ "no-cache") ) {
         set beresp.ttl = 3600s;
         set beresp.http.Cache-Control = "public, max-age=600";
    }
    # set grace period
    set beresp.grace = 1d;
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.

    # add cache response header
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }
    unset resp.http.X-Purge-URL;
}

sub vcl_hit {
	# deliver if ttl > 0, normal hit
	if (obj.ttl >= 0s) {
		return (deliver);
	}
	# deliver if ttl = 0 but grace still on
	if (obj.ttl + obj.grace > 0s) {
		return (deliver);
	}
	# fetch new content
	return (fetch);
}
