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