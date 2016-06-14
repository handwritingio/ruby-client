# Handwriting.io Client

TODO Links and Badges

## Installation

TODO Gem install command

## Basic Example

Set up the client, render an image, and write it to a file:

```ruby
# TODO: Example code here
```

If all goes well, this should create an image similar to the following:

![image](https://s3.amazonaws.com/hwio-cdn-production/ruby-client/handwriting.png)

## Advanced Examples

Overlaying handwriting on a background image:

```ruby
# TODO Example Code
```

It should create an image like this : [handwriting_overlay.png](https://s3.amazonaws.com/hwio-cdn-production/ruby-client/handwriting_overlay.png)

## Reference

See the [API Documentation](https://www.handwriting.io/docs) for details on all endpoints and parameters. For the most part, the Client passes parameters through to the API directly.

The endpoints map to client methods as follows:

- [GET /handwritings](https://handwriting.io/docs/#get-handwritings) -> `Client#handwritings(params)`
- [GET /handwritings/{id}](https://handwriting.io/docs/#get-handwritings--id-) -> `Client#handwriting(handwriting_id)`
- [GET /render/png](https://handwriting.io/docs/#get-render-png) -> `Client#render_png(params)`
- [GET /render/pdf](https://handwriting.io/docs/#get-render-pdf) -> `Client#render_pdf(params)`

## Version Numbers

Version numbers for this package work slightly differently than standard
[semantic versioning](http://semver.org/). For this package, the `major`
version number will match the Handwriting.io API version number, and the
`minor` version will be  incremented for any breaking changes to this package.
The `patch` version will be incremented for bug fixes and changes that add
functionality only.

## Issues

Please open an issue on [Github](https://github.com/handwritingio/ruby-client/issues)
or [contact us](https://handwriting.io/contact) directly for help with any
problems you find.