#!/bin/bash
git checkout stg || {echo "Err raised"; exit 1;}
git merge dev --no-ff -m "automerge"
TAG="merge-$(date +%Y%m%d-%H%M%S)"
git push origin stg
git push origin "$TAG"
