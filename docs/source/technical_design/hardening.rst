=============================
Production: Hardening OpenKAT
=============================

Hardening is making your environment secure. The default installation of OpenKAT is suitable for local use. If you are installing the software in a production environment, make sure you are running a secure configuration. The following modifications are a first step:

Password Django installation
============================

In the django config (/admin on rocky), change the default password of the admin:admin user.

SESSION_COOKIE_AGE
==================

Rocky is the web interface. It sets cookies for sessions of 1209600 seconds, or 2 weeks. This is quite long and can be adjusted with a new entry in rocky/settings.py.
Sessions are limited to 2 hours based on the default configuration.

Security headers
================

Rocky expects a reverse proxy that can handle TLS. This is a good place to set the security headers:

+-------------------------------------------+------------------------------------------+
| Header				    | Settings				       |
+-------------------------------------------+------------------------------------------+
| X-Frame-Options			    | Deny				       |
+-------------------------------------------+------------------------------------------+
| X-Content-Type-Options		    | nosniff				       |
+-------------------------------------------+------------------------------------------+
| Content-Security-Policy		    | default-src 'self'; object-src 'none';   |
|					    | child-src 'self'; frame-ancestors 'none';|
|					    | upgrade-insecure-requests; 	       |
|					    | block-all-mixed-content		       |
+-------------------------------------------+------------------------------------------+
| X-Permitted-Cross-Domain-Policies	    | none				       |
+-------------------------------------------+------------------------------------------+
| Referrer-Policy			    | no-referrer			       |
+-------------------------------------------+------------------------------------------+
| Clear-Site-Data			    | "cache","cookies","storage" (Opt. bij    |
|					    | reverse NGINX proxies, "cookies" weglaten|
+-------------------------------------------+------------------------------------------+
| Cross-Origin-Embedder-Policy (COEP)	    | require-corp			       |
+-------------------------------------------+------------------------------------------+
| Cross-Origin-Opener-Policy (COOP)	    | same-origin			       |
+-------------------------------------------+------------------------------------------+
| Cross-Origin-Resource-Policy (CORP)	    | same-origin			       |
+-------------------------------------------+------------------------------------------+
| Permissions-Policy			    | accelerometer=(),autoplay=(),camera=(),  |
|					    | display-capture=(),document-domain=(),   |
|					    | encrypted-media=(),fullscreen=(),        |
|					    | geolocation=(), gyroscope=(), 	       |
|					    | magnetometer=(), microphone=(), midi=(), |
|					    | payment=(), picture-in-picture=(),       |
| 					    | publickey-credentials-get=(),            |
|					    | screen-wake-lock=(),sync-xhr=(self),     |
|					    | usb=(),web-share=(),		       |
|					    | xr-spatial-tracking=()		       |
+-------------------------------------------+------------------------------------------+
| Cache-Control				    | no-store, max-age=0		       |
+-------------------------------------------+------------------------------------------+
| Pragma				    | no-cache				       |
+-------------------------------------------+------------------------------------------+
| X-DNS-Prefetch-Control		    | off				       |
+-------------------------------------------+------------------------------------------+
| Expect-CT				    | max-age=86400, enforce		       |
+-------------------------------------------+------------------------------------------+

SSL/TLS on nginx
================

Use the following versions and settings for SSL/TLS on nginx:

- ssl_protocols TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
- ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
- ssl_ecdh_curve secp384r1; # Requires nginx >= 1.1.0
- ssl_session_tickets off; # Requires nginx >= 1.5.9
- ssl_stapling on; # Requires nginx >= 1.3.7
- ssl_stapling_verify on; # Requires nginx => 1.3.7
- ssl_prefer_server_ciphers on;
- ssl_session_timeout 10m;
- ssl_session_cache shared:SSL:10m;

Optional use of HSTS, including for subdomains.

``add_header Strict-Transport-Security "max-age=31104000;" always;``

Obscuring errors to the clients
===============================

By default, errors in OpenKAT are visible to the user. The reverse proxy can restrict this and return a generic error message.

``proxy_intercept_errors on;
error_page 500 502 503 504 /error.html;``

In addition, it makes sense to prevent the proxy itself from sending its version along with each response:

``server_tokens off;``

Web Application Firewall
========================

Installing KAT (rocky) behind a WAF provides an additional layer of security. Modsecurity, which is part of the reverse proxy, can be used for this purpose. More information can be found on the project's Github page:

- https://github.com/SpiderLabs/ModSecurity
- https://github.com/SpiderLabs/ModSecurity-nginx

Continue reading
================

Much more information is available on this topic. When applying OpenKAT in a production environment, the following links offer a first step:

- https://developer.mozilla.org/en-US/docs/Learn/Server-side/Django/web_application_security
- https://owasp.org/www-project-secure-headers/
- https://docs.djangoproject.com/en/4.0/topics/security/



