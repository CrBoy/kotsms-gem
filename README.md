KOTSMS
======

This project is a simple wrapper of [簡訊王][kotsms] API, which is developed by third-party.
The official API document is [here][apidoc].
It has four functions: send message, send bulk of messages, get the balance, and get the status of delivery.

[kotsms]: http://www.kotsms.com.tw "簡訊王"
[apidoc]: https://www.kotsms.com.tw/index.php?selectpage=pagenews&kind=4&viewnum=238 "API Document"


Developer's note (and murmur)
-----------------------------

- The document guide to use GET method. However POST method is allowed as well. This would be changed in the future version.
- `doc/kotsms-api.yml` is the api document in [Swagger][] 2.0 format.
- Does anyone know what does the "kot" mean?

[Swagger]: http://swagger.io "Swagger"


Contributor
------------

- CrBoy (Sharelike, [http://sharelike.asia]())
