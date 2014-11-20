
TODO:cleanup/revise information herein is no longer valid


# vibe:namespaces

vibe:namespaces adds namespaces to your Meteor applications and packages.

Besides of that, vibe:namespaces is actually agnostic to the environment it
is running in.


## Installation

You can install vibe:namespaces in multiple different ways.


### Install from Atmosphere

This is the most easiest way to install the package. Just run

    meteor add 'vibe:namespaces'

and off you go.


### Install into Packages Folder

You might also want to install the vibe:namespaces package into your Meteor
application's packages folder. Either by cloning the repository directly or
making it a submodule of your git repository.

The benefit of such an installation will be that you can always have a look
at the original sources, generate the require API documentation from these
sources and, what is most benefitial, you can easily switch between release
tags and even branches. Or, you might want to create your own temporary
branch for tweaking things or testing things out.

Once you have cloned the repository into your packages folder, simply run

    meteor add 'vibe:namespaces'

and off you go.


TODO:

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

