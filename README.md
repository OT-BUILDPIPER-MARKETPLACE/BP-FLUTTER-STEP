# BP-FLUTTER-STEP
A BP step to orchestrate flutter execution

## Setup
* Clone the code available at [BP-TRIVY-STEP](https://github.com/OT-BUILDPIPER-MARKETPLACE/BP-FLUTTER-STEP)
* Build the docker image
```
git submodule init
git submodule update
docker build -t ot/flutter:0.1 .
```

* Do local testing via image only
```
# Build android code with default settings 
docker run -it --rm -v $PWD:/src -e WORKSPACE=/src -e CODEBASE_DIR=/ ot/flutter:0.1

# Do test
docker run -it --rm -v $PWD:/src -e WORKSPACE=/src -e CODEBASE_DIR=/ -e INSTRUCTION=test ot/flutter:0.1

# Debug
docker run -it --rm -v $PWD:/src --entrypoint sh -e WORKSPACE=/src -e CODEBASE_DIR=/ ot/flutter:0.1
```


## References
https://github.com/cirruslabs/docker-images-flutter/pkgs/container/flutter