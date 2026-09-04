 Docker decisons

 - Scratch runtime - have to manually copy CA certs ; worth for slimmer image 

 - Explicit alpine version in runtime to avoid latest breaking it

 - Multi-stage build to reduce image size



runtime multibuild steps:
 Scratch = Ditsroless
- find out requirements
- copy app, config, ssl certs
expose port 8080
ENTRYPOINT