#
# Copyright 2014 Carsten Klein
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and 
# limitations under the License.
#


# we export most of this to the global namespace
exports = if typeof(global) == 'undefined' then window else global


# The default context **nsDefaultContext** being used for declaring namespaces in.
# On the server this will default to **global**, whereas on the client aka browser
# this will default to **window**.
#
# @type Object
# @readonly
# @memberof vibejs.lang
nsDefaultContext = exports


# Guard preventing Namespace constructor from being called directly.
nsDeclaring = false


# The regular expression used for validating user provided namespace
# identifiers.
#
#    /^[a-zA-Z_$]+[a-zA-Z_$0-9]*(?:[.][a-zA-Z_$]+[a-zA-Z_$0-9]*)*$/
#
# @type {RegExp}
# @readonly
# @memberof vibejs.lang.constants
NS_QNAME_RE = /^[a-zA-Z_$]+[a-zA-Z_$0-9]*(?:[.][a-zA-Z_$]+[a-zA-Z_$0-9]*)*$/


# The class **Namespace** models a container for user defined properties and 
# namespaces.
#
# Instances of this can only be created using {@link Namespaces.nsDeclare}.
# 
# exposed for testing purposes and instanceof checks only
#
# @class
# @property {String} nsQualifiedName - the qualified name of this (readonly)
# @property {Namespaces.Namespace} nsParent - the parent namespace or null (readonly)
# @property {Object} nsNamespaces - the direct child namespaces of this or the empty hash (readonly)
# @property {Object} nsClasses - the classes declared in this or the empty hash (readonly)
# @property {Object} nsFunctions - the functions declared in this or the empty hash (readonly)
# @property {Object} nsObjects - the objects declared in this or the empty hash (readonly)
# @property {Object} nsScalars - the scalars declared in this or the empty hash (readonly)
# @memberof vibejs.lang
class Namespace

    constructor: (localName, parent, logger) ->

        if not nsDeclaring

            throw new TypeError 'Namespace must not be instantiated directly. Use namespace instead.'

        cachedQualifiedName = null
        frozen = false

        if parent and not (parent instanceof Namespace)

            throw new TypeError 'parent must be an instance of vibejs.lang.namespace.Namespace'

        # make sure that the logger has a debug method
        if logger and not 'function' == typeof logger.debug

            throw new TypeError 'logger does not have a debug(...) method.'

        # @property String _logger optional logger used for debugging
        # @private
        # @readonly
        Object.defineProperty @, '_logger',

            enumerable : false

            get : ->

                logger

        @_logger?.debug "Namespace:constructor:localName = #{localName}"
        @_logger?.debug "Namespace:constructor:parent = #{parent?.nsQualifiedName}"

        # @property String nsLocalName the local name of this
        # @readonly
        Object.defineProperty @, 'nsLocalName',

            enumerable : false 

            get : ->

                return localName

        # @property Namespace nsParent the parent namespace of this or null
        # @readonly
        Object.defineProperty @, 'nsParent',

            enumerable : false

            get : ->

                parent

        # @property String nsQualifiedName the qualified name of this
        # @readonly
        Object.defineProperty @, 'nsQualifiedName',

            enumerable : false

            get : ->

                if cachedQualifiedName is null

                    @_logger?.debug "Namespace:nsQualifiedName:building qualified name"

                    components = []
                    ns = @ 

                    while ns?

                        components.push ns.nsLocalName
                        ns = ns.nsParent

                    components.reverse()
                    cachedQualifiedName = components.join '.'

                    @_logger?.debug "Namespace:nsQualifiedName:built qualified name #{cachedQualifiedName}"

                return cachedQualifiedName

        # @property String name alias for nsQualifiedName
        # @readonly
        Object.defineProperty @, 'name',

            enumerable : false

            get : ->

                @nsQualifiedName

        # @property Boolean nsFrozen true whether this was frozen, false otherwise
        # @readonly
        Object.defineProperty @, 'nsFrozen',

            enumerable : false

            get : ->

                frozen

        # Extends this by the specified declarations. Will not override existing members of
        # this unless told otherwise.
        #
        # @method nsExtend
        # @param Object 
        # @return this
        # @throws Error thrown in case that this was frozen
        Object.defineProperty @, 'nsExtend',

            enumerable : false

            get : ->

                if @nsFrozen

                    @_logger?.debug "Namespace:nsExtend:attempted to extend frozen namespace #{@nsQualifiedName}"

                    throw new Error "namespace #{@nsQualifiedName} is frozen and cannot be extended."

                (options = {}) ->

                    @_logger?.debug "Namespace:nsExtend:extending namespace #{@nsQualifiedName}"

                    override = if options.override == true then true else false

                    configurable = if options.configurable == false then false else true
                    declarations = options.extend || {}

                    for key of declarations

                        if @[key] is undefined or override

                            enumerable = /^_/.exec(key) is null

                            @_logger?.debug "Namespace:nsExtend:defining #{key} = #{declarations[key]}"

                            if not enumerable

                                @_logger?.debug "Namespace:nsExtend:defining #{key} non enumerable"

                            if not configurable

                                @_logger?.debug "Namespace:nsExtend:defining #{key} non configurable"

                            if not configurable or not enumerable

                                applier = (key, value) ->

                                    Object.defineProperty @, key,

                                        enumerable : enumerable 

                                        configurable : configurable 

                                        writable : configurable 

                                        value : value

                                applier.call @, key, declarations[key]

                                @_logger?.debug "Namespace:nsExtend:defined #{key}"

                            else

                                @[key] = declarations[key]

                                @_logger?.debug "Namespace:nsExtend:defined #{key}"

                        else

                            @_logger?.debug "Namespace:nsExtend:not overriding existing #{key}"

                    @

        # Freezes this so that it can no longer be extended or modified.
        # Calling this multiple times has no effect.
        #
        # @return this
        Object.defineProperty @, 'nsFreeze',

            enumerable : false

            get : ->

                ->

                    if not frozen

                        @_logger?.debug "Namespace:nsFreeze:trying to freeze namespace #{@nsQualifiedName}"

                        freezer = Object.freeze || Object.seal

                        if freezer

                            frozen = true

                            freezer @

                            @_logger?.debug "Namespace:nsFreeze:namespace #{@nsQualifiedName} was frozen"

                        else

                            @_logger?.debug "Namespace:nsFreeze:neither Object.freeze nor Object.seal are available"

                    @

    # Returns an object containing the children of this or this if no filter object or function was
    # specified.
    #
    # The filter function or method must accept two arguments, namely key and value.
    #
    # @method nsChildren
    # @param Function|Object:null a filter function or object with a filter method or function
    # @return Object the filtered children or this
    # @throws Error thrown in case that filter is not null and not a function or object
    #               with either a filter function or method
    Object.defineProperty @::, 'nsChildren',

        enumerable : false

        get : ->
    
            (filter = null) ->

                result = @

                actualFilter = filter
                if filter != null and 'object' == typeof filter

                    actualFilter = filter.filter

                if actualFilter is undefined

                    throw new TypeError 'filter must be either a function or object with a filter method or function'

                if actualFilter

                    result = {}

                    for key of @

                        if actualFilter(key, @[key])

                            result[key] = @[key]

                result


# The function namespace models a factory for instances of type Namespace.
#
# TODO:document
#
# @param String qname the qualified name of the namespace
# @param Object options additional parameters
# @option options Object|Namespace:nsDefaultContext context the context to which the resulting namespace will be assigned to
# @option options Boolean:false freeze determines whether the resulting namespace will be frozen so that
#                                      it cannot be extended
# @option options Object:null extend optional namespace extension
# @option options Object:null logger optional logger for outputting debug information
# @memberof vibejs.lang
exports.namespace = (qname, options = {})->

    result = null

    logger = options.logger || null
    context = options.context || nsDefaultContext

    # make sure that the logger has a debug method
    if logger and not 'function' == typeof logger.debug

        throw new TypeError 'logger does not have a debug(...) method.'

    logger?.debug "namespace:get or declare namespace #{qname} in context #{context.name || if context == nsDefaultContext then 'default' else 'user defined'}"

    # make sure that qname is valid
    if qname is null or
       qname is undefined or
       null == NS_QNAME_RE.exec qname

        throw new TypeError "invalid qname '#{qname}'."

    # declare namespaces in their reverse order
    currentContext = context
    components = qname.split '.'
    components.reverse()
    while components.length

        # TODO:logging

        localName = components.pop()
        localns = currentContext[localName]

        if localns is undefined

            # associate parent namespace
            parent = null
            if currentContext instanceof Namespace

                parent = currentContext

                # fail early in case that parent is frozen
                if parent.nsFrozen

                    throw new Error "namespace #{parent.nsQualifiedName} is frozen and cannot be extended."

            # declare and finalize namespace
            nsDeclaring = true
            localns = new Namespace localName, parent, logger
            nsDeclaring = false

            if /^_/.exec(localName) is null

                currentContext[localName] = localns

            else

                Object.defineProperty currentContext, localName,

                    enumerable : false

                    value : localns

        else if not (localns instanceof Namespace)

            key = localName
            if currentContext instanceof Namespace

                key = "#{currentContext.nsQualifiedName}.#{localName}"

            throw new Error "will not redeclare existing value for key #{key} in the specified context"

        currentContext = result = localns

    if options.extend

        result.nsExtend options

    if options.freeze == true

        result.nsFreeze()

    result


# @namespace vibejs.lang
namespace 'vibejs.lang',

    configurable : false

    extend :

        nsDefaultContext : nsDefaultContext

        Namespace : Namespace

        namespace : namespace


# @namespace vibejs.lang.constants
namespace 'vibejs.lang.constants',

    configurable : false

    extend :

        NS_QNAME_RE : NS_QNAME_RE

