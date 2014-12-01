# vibejs-namespaces

[![Build Status](https://travis-ci.org/vibejs/vibejs-namespaces.svg?branch=master)](https://travis-ci.org/vibejs/vibejs-namespaces)

## Introduction

*namespaces* adds sophisticated namespace support to your Javascript/Coffee-Script applications.


### Motivation

namespaces was primarily implemented for use with Coffee-Script in conjunction with Meteor to overcome
both its current "limitations" with ordering of and packaging the existing source files for
deployment and to leverage the overhead of authoring the package descriptor package.js.

With namespaces, one can simply use api.addFiles(...) instead of also having to export individual
entities by their name.

Having reviewed existing libraries that implement namespaces, it soon became clear that these libraries
will simply not do the trick and that yet another namespace providing library needs to be made.


### Features

 - namespace factory registered with the global context for declaring namespaces
 - namespaces can be extended either on creation or afterwards using the Namespace#nsExtend method
 - namespaces can be bound to either the global context or a custom context
 - namespaces can be frozen so that they can no longer be extended
 - namespaces can be traversed using Namespace#nsParent or Namespace#nsChildren(...) or simply by
   accessing the namespace objects directly from within their declaring context
 - vibejs.lang.namespace namespace exposing the namespace function, the Namespace class and
   a few other useful things
 - all or individual members of a namespace can be made non enumerable by prefixing their keys with '_'
 - all or individual members of a namespace can be made non configurable, i.e. readonly
 - namespaces can be made non enumerable, making them sort of private/internal,
   by prefixing their local name with '_'


## LICENSE


   Copyright 2014 Carsten Klein

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   

## Installation

You can install namespaces in multiple different ways.


### Node NPM

    npm [-g] install vibejs-namespaces


### Meteor

    meteor add vibejs:namespaces


## Usage


### Node - Javascript

    var util = require('util');
    require('vibejs-namespaces');

    namespace('tool', { extend : { NAME : 'Ingenious Tool' } });

    namespace('tool.core.commands');

    var BaseCommand = function (name) { this.name = name; };
    BaseCommand.prototype.execute = function () {};

    var AboutCommand = function () { this.prototype.super_.call(this, 'about'); };
    util.inherits(AboutCommand, BaseCommand);

    AboutCommand.prototype.execute = function () {

        console.log(tool.NAME + ": " + this.name);

    tool.core.commands.nsExtend({
        BaseCommand : BaseCommand,
        AboutCommand : AboutCommand
    });


### Node - Coffee-Script

    require 'vibejs-namespaces'

    namespace 'tool',

        extend :

            NAME : 'Ingenious Tool'

    namespace 'tool.core.commands',

        extend :

            BaseCommand : class BaseCommand

                constructor : (@name) ->

                execute : ->

            AboutCommand : class AboutCommand extends BaseCommand

                constructor : ->

                    super 'about'

                execute : ->

                    console.log "#{tool.NAME}: #{@name}"


### Meteor - Javascript (both Client and Server)

TODO


### Meteor - Coffee-Script (both Client and Server)

TODO
