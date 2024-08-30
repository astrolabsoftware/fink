More will be added as we spot problems.

## Status code

When using the REST API, you should first check the _status code_. Status code is a three-digit number returned by the server in response to your request. It indicates the outcome of the request and provides information about whether it was successful, encountered an error, or requires further action. [Status codes](https://www.rfc-editor.org/rfc/rfc2616#page-39) are part of the HTTP (Hypertext Transfer Protocol) standard. Long story short, if you do not get `200`, something bad has happened! The most common status codes are:

- **200 OK:** The request was successful, and the server returned the requested data.
- **400 Bad Request:** The server could not understand the request due to invalid syntax. Usually check the arguments you provided.
- **500 Internal Server Error:** The server encountered an unexpected condition that prevented it from fulfilling the request. Fink had typically an internal error. Let us know if that persists.
- **503 Service Unavailable:** The server is currently unable to handle the request due to temporary overload or maintenance. Fink is dead.