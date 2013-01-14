#!/bin/bash
cd $(dirname $0)
cp ../../service.yml ../../regular-service.yml
mv ../../acceptance-test.yml.example ../../service.yml

