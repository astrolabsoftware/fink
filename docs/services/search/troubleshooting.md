If all goes well, you should receive your data. You should first check the _status code_. status code is a three-digit number returned by the server in response to your request. It indicates the outcome of the request and provides information about whether it was successful, encountered an error, or requires further action. [Status codes](https://www.rfc-editor.org/rfc/rfc2616#page-39) are part of the HTTP (Hypertext Transfer Protocol) standard. Long story short, if you do not get `200`, something bad has happened!


200 OK: The request was successful, and the server returned the requested data.
[client error, aka your fault] 400 Bad Request: The server could not understand the request due to invalid syntax.
[server error, aka Fink's fault] 500 Internal Server Error: The server encountered an unexpected condition that prevented it from fulfilling the request.
[Fink is dead] 503 Service Unavailable: The server is currently unable to handle the request due to temporary overload or maintenance.