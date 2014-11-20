
TODO:cleanup/revise information herein is no longer valid


# namespaces


## Introduction

namespaces adds sophisticated namespace support to your Javascript/Coffee-Script applications.


### Motivation

namespaces was primarily implemented for use with Coffee-Script in conjunction with Meteor to overcome
both its current "limitations" with ordering of and packaging the existing source files for 
deployment and to leverage the overhead of authoring the package descriptor package.js.

With namespaces, one can simply use api.addFiles(...) instead of also having to export individual
entities by their name.

Also, the available libraries that add namespace support to one's application simply did not meet
our overall requirements.


### Features

 - namespace factory registered with the global object
 - namespaces can be extended either on creation or afterwards using the Namespace#nsExtend method
 - namespaces can be bound to either the global context or a custom context
 - namespaces can be frozen so that they can no longer be extended
 - namespaces can be traversed using Namespace#nsParent or Namespace#nsChildren(...)
 - vibe.namespace namespace exposing the namespace function, the Namespace class and 
   a few other useful things
 - COMING SOON: namespaces can be made non enumerable, making them sort of private/internal


## Installation

You can install namespaces in multiple different ways.


### NPM

    npm [-g] install namespaces


### Meteor

    meteor add vibe:namespaces


## Usage

TODO

/**
 * <h2>Usage</h2>
 *
 * <h3>Declaring a new Root Namespace in the Global Context</h3>
 *
 * <pre>
 * Namespaces.declare('tool', {
 *     f : function () {
 *         console.log('hello namespace');
 *     }
 * });
 * tool.f();
 * </pre>
 *
 * <h3>Declaring a Namespace hierarchy using Window as the Context</h3>
 *
 * <pre>
 * Namespaces.declare('tool.actions', {
 *     undo : function () {
 *         console.log('undoing');
 *     }},
 *     window
 * );
 * window.tool.actions.undo();
 * </pre>
 *
 * <h3>Declaring a Child Namespace</h3>
 *
 * <pre>
 * tool.declare('logging', {
 *     debug : function (msg) {
 *         console.log('debug: ' + msg);
 *     }}
 * );
 * tool.logging.debug('child namespace');
 * </pre>
 *
 * <h3>Extending an Existing Namespace</h3>
 *
 * <pre>
 * tool.extend({
 *     _f : tool.f, // save existing declaration of tool.f
 *     f : function () { console.log('f says:'); this._f(); },
 *     f2 : function () { console.log('hello from f2'); }
 * });
 * </pre>
 */

