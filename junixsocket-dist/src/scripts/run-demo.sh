#!/bin/bash
#
# junixsocket
#
# Copyright (c) 2009-2018 Christian Kohlschütter
#
# The author licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

useModulePath=0
printHelp=0

extraJars=()
while [ -n "$1" ]; do
  case "$1" in
   -m)
    echo "Using module path"
    useModulePath=1
    ;;
   -j)
    shift
    if [ -n "$1" ]; then
      jar="$1"
      extraJars+=("$jar")
    else
      echo "Missing parameter for -j" >&2
      exit 1
    fi
    ;;
   -h|--help)
     printHelp=1
     ;;
   --)
    shift
    break;
    ;;
   -*)
     echo "Illegal option: $1" >&2
     exit 1
    ;;
   *)
    break
    ;;
  esac
  shift
done

lastArg="${@: -1}"
if [[ "$lastArg" =~ '/^-/' || -z "$lastArg" ]]; then
  printHelp=1
fi

mysqlJar="$HOME/.m2/repository/mysql/mysql-connector-java/8.0.13/mysql-connector-java-8.0.13.jar"
if [ ! -f "$mysqlJar" ]; then
  mysqlJar="<path-to-mysql-conncetor-jar>"
fi

if [[ $# -eq 0 || $printHelp -eq 1 ]]; then
  cat >&2 <<EOT
Syntax: $0 [-m] [-j jar]+ [-- [java opts]*] <classname>

Example:
# Runs the demo server
$0 org.newsclub.net.unix.demo.SimpleTestServer
# Runs the demo client
$0 org.newsclub.net.unix.demo.SimpleTestClient

# Runs the demo RMI server
$0 org.newsclub.net.unix.demo.rmi.SimpleRMIServer
# Runs the demo RMI client
$0 org.newsclub.net.unix.demo.rmi.SimpleRMIClient

# Runs the MySQL demo
$0 -j "$mysqlJar" -- -DmysqlSocket=/tmp/mysql.sock org.newsclub.net.mysql.demo.AFUNIXDatabaseSocketFactoryDemo

Other flags:
 -m Use the Java module-path instead of the classpath (Java 9 or higher)
 -j <jar> Add the given jar to the beginning of the classpath/modulepath
 -- Separate the run-demo flags from the Java JVM flags
EOT
  exit 1
fi
libDir="$(dirname $0)/lib"
java -cp "$libDir"/"*" $@

path="$libDir"$(for f in ${extraJars[@]} $(ls "$libDir"/*.jar); do echo -n ":$f"; done)
echo $path
if [ $useModulePath -eq 1 ]; then
  java --module-path="$path" -Djdk.module.main=org.newsclub.net.unix.demo $@
else
  java -cp "$path" $@
fi
