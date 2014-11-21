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


vows = require 'vows'
assert = require 'assert'

require '../src/namespaces'



# add enumerable macro
assert.isEnumerable = (obj, key, message = null) ->

    if obj is undefined or obj is null

        throw new TypeError 'obj is null or undefined'

    if key is undefined or key is null or key == ''

        throw new TypeError 'key is undefined or null or the empty string'

    if not (key in Object.keys obj)

        assert.fail null, null, message || "key '#{key}' is not enumerable", "isEnumerable", assert.isEnumerable


assert.isNotEnumerable = (obj, key, message = null) ->

    if obj is undefined or obj is null

        throw new TypeError 'obj is null or undefined'

    if key is undefined or key is null or key == ''

        throw new TypeError 'key is undefined or null or the empty string'

    if key in Object.keys obj

        assert.fail null, null, message || "key '#{key}' is enumerable", "isNotEnumerable", assert.isNotEnumerable


assert.isFrozen = (obj, message = null) ->

    if obj is undefined or obj is null

        throw new TypeError 'obj is null or undefined'

    if not Object.isFrozen obj

        assert.fail null, null, message || "obj is not frozen", "isFrozen", assert.isFrozen


assert.isNotFrozen = (obj, message = null) ->

    if obj is undefined or obj is null

        throw new TypeError 'obj is null or undefined'

    if Object.isFrozen obj

        assert.fail null, null, message || "obj is frozen", "isNotFrozen", assert.isNotFrozen


vows
    .describe 'vibe.namespace'
    .addBatch

        'NS_QNAME_RE' :

            topic : ->

                vibe.namespace.NS_QNAME_RE

            'must not match empty string or whitespace' : (topic) ->

                assert.isNull topic.exec ''
                assert.isNull topic.exec ' '
                assert.isNull topic.exec 'identifier '

            'must not match non identifier' : (topic) ->

                assert.isNull topic.exec '1nonidentifier'
                assert.isNull topic.exec '-nonidentifier'
                assert.isNull topic.exec 'non-identifier'

            'must not match qualified non identifier' : (topic) ->

                assert.isNull topic.exec 'non.1identifier'
                assert.isNull topic.exec 'non.-identifier'
                assert.isNull topic.exec 'non.id-dentifier'

            'must not match malformed identifier' : (topic) ->

                assert.isNull topic.exec '.mal.formed'
                assert.isNull topic.exec 'mal..formed'

            'must match valid identifier' : (topic) ->

                assert.equal topic.exec('identifier')[0], 'identifier'
                assert.equal topic.exec('_identifier')[0], '_identifier'
                assert.equal topic.exec('$identifier')[0], '$identifier'
                assert.equal topic.exec('identifier_')[0], 'identifier_'
                assert.equal topic.exec('identifier$')[0], 'identifier$'
                assert.equal topic.exec('identifier1')[0], 'identifier1'

            'must match valid qualified identifier' : (topic) ->

                assert.equal topic.exec('id.entifier')[0], 'id.entifier'
                assert.equal topic.exec('_id.entifier')[0], '_id.entifier'
                assert.equal topic.exec('$id.entifier')[0], '$id.entifier'
                assert.equal topic.exec('id.entifier_')[0], 'id.entifier_'
                assert.equal topic.exec('id.entifier$')[0], 'id.entifier$'
                assert.equal topic.exec('id.entifier1')[0], 'id.entifier1'

        'nsDefaultContext' :

            topic : ->

                vibe.namespace.nsDefaultContext

            'must be equal to window (browser) or global (node)' : (topic) ->

                assert.strictEqual topic, if window? then window else global

        'namespace' :

            'must fail on null qname' : ->

                cb = ->

                    namespace null

                assert.throws cb, TypeError

            'must fail on undefined qname' : ->

                cb = ->

                    namespace undefined

                assert.throws cb, TypeError

                cb = ->

                    namespace()

                assert.throws cb, TypeError

            'must fall back to nsDefaultContext on null context' : ->

                cb = ->

                    namespace 'toplevelns', null

                assert.doesNotThrow cb, Error
                assert.isTrue vibe.namespace.nsDefaultContext['toplevelns'] instanceof vibe.namespace.Namespace
                assert.deepEqual vibe.namespace.nsDefaultContext['toplevelns'], {}

                delete vibe.namespace.nsDefaultContext['toplevelns']

            'must fall back to nsDefaultContext on undefined context' : ->

                cb = ->

                    namespace 'toplevelns', undefined

                assert.doesNotThrow cb, Error
                assert.isTrue vibe.namespace.nsDefaultContext['toplevelns'] instanceof vibe.namespace.Namespace
                assert.deepEqual vibe.namespace.nsDefaultContext['toplevelns'], {}

                delete vibe.namespace.nsDefaultContext['toplevelns']

            'must return declared namespace' : ->

                top = namespace 'toplevelns'
                assert.isNotNull top
                assert.deepEqual vibe.namespace.nsDefaultContext['toplevelns'], top

                delete vibe.namespace.nsDefaultContext['toplevelns']

            'must return declared sub namespace' : ->

                sub = namespace 'toplevelns.sub'
                assert.isNotNull sub
                assert.deepEqual vibe.namespace.nsDefaultContext['toplevelns'].sub, sub

                delete vibe.namespace.nsDefaultContext['toplevelns']

            'declared namespace must be a defined property of its context' : ->

                namespace 'toplevelns'
                assert.isTrue vibe.namespace.nsDefaultContext.hasOwnProperty 'toplevelns'

                delete vibe.namespace.nsDefaultContext['toplevelns']

            'declared namespace must be an enumerable property of its context' : ->

                namespace 'toplevelns'
                found = false
                assert.isEnumerable vibe.namespace.nsDefaultContext, 'toplevelns'

                delete vibe.namespace.nsDefaultContext['toplevelns']

            'declared namespace must be a deletable property of its context' : ->

                namespace 'toplevelns'
                delete vibe.namespace.nsDefaultContext['toplevelns']

                assert.isUndefined vibe.namespace.nsDefaultContext['toplevelns']

            'must create hierarchy of namespaces from a qualified identifier' : ->

                sub = namespace 'toplevelns.sub'
                top = vibe.namespace.nsDefaultContext['toplevelns']

                assert.deepEqual top, { sub : sub }

                delete vibe.namespace.nsDefaultContext['toplevelns']

            'must not redeclare existing namespace' : ->

                top = namespace 'toplevelns'
                top.a = 1
                sub = namespace 'toplevelns.sub'

                assert.deepEqual top, { a: 1, sub : {} }

                delete vibe.namespace.nsDefaultContext['toplevelns']

            'must fail when encountering non namespace and not redeclare existing key' : ->

                top = namespace 'toplevelns'
                top.sub = 1

                cb = ->

                    namespace 'toplevelns.sub'

                assert.throws cb, Error

                delete vibe.namespace.nsDefaultContext['toplevelns']

        'Namespace instances must have default properties and methods that are not enumerable' :

            'nsLocalName' : ->

                top = namespace 'toplevelns'

                assert.isDefined top, 'nsLocalName'
                assert.isNotEnumerable top, 'nsLocalName'
                assert.equal top.nsLocalName, 'toplevelns'

                delete vibe.namespace.nsDefaultContext['toplevelns']
 
            'nsQualifiedName' : ->

                sub = namespace 'toplevelns.sub'

                assert.isDefined sub, 'nsQualifiedName'
                assert.isNotEnumerable sub, 'nsQualifiedName'
                assert.equal sub.nsQualifiedName, 'toplevelns.sub'

                delete vibe.namespace.nsDefaultContext['toplevelns']

            'nsParent' : ->

                sub = namespace 'toplevelns.sub'
                top = vibe.namespace.nsDefaultContext['toplevelns']

                assert.isDefined top, 'nsParent'
                assert.isNotEnumerable top, 'nsParent'
                assert.deepEqual top, sub.nsParent

                delete vibe.namespace.nsDefaultContext['toplevelns']

            'nsChildren' : ->

                top = namespace 'toplevelns'

                assert.isDefined top, 'nsChildren'
                assert.isNotEnumerable top, 'nsChildren'
                assert.isFunction top.nsChildren

                delete vibe.namespace.nsDefaultContext['toplevelns']

            'nsFrozen' : ->

                top = namespace 'toplevelns'

                assert.isDefined top, 'nsFrozen'
                assert.isNotEnumerable top, 'nsFrozen'
                assert.isFalse top.nsFrozen

                delete vibe.namespace.nsDefaultContext['toplevelns']

            'nsFreeze' : ->

                top = namespace 'toplevelns'

                assert.isDefined top, 'nsFreeze'
                assert.isNotEnumerable top, 'nsFreeze'
                assert.isFunction top.nsFreeze

                delete vibe.namespace.nsDefaultContext['toplevelns']

            'nsExtend' : ->

                top = namespace 'toplevelns'

                assert.isDefined top, 'nsExtend'
                assert.isNotEnumerable top, 'nsExtend'
                assert.isFunction top.nsExtend

                delete vibe.namespace.nsDefaultContext['toplevelns']

            '_logger' : ->

                top = namespace 'toplevelns'

                assert.isNotEnumerable top, '_logger'

                delete vibe.namespace.nsDefaultContext['toplevelns']

        'namespace with option freeze set to true must' :

            topic : ->

                namespace 'frozentoplevelns',

                    freeze : true

                    extend :

                        prop1 : 1

            'freeze the namespace' : (topic) ->

                assert.isFrozen topic

            'prevent namespace properties from being altered' : (topic) ->

                topic.prop1 = 5
                assert.equal topic.prop1, 1

            'prevent namespace properties from being deleted' : (topic) ->

                delete topic.prop1
                assert.isDefined topic.prop1
                assert.equal topic.prop1, 1

            'prevent the user from adding new properties' : (topic) ->

                topic.prop2 = 2
                assert.isUndefined topic.prop2

            teardown : ->

                delete vibe.namespace.nsDefaultContext['frozentoplevelns']

        'Namespace#nsExtend()' :

            topic : ->

                namespace 'extendedtoplevelns',

                    extend :

                        prop1 : 1

            'by default must not override existing properties' : (topic) ->

                topic.nsExtend

                    prop1 : 2

                assert.equal topic.prop1, 1

            'must override existing properties when told to do so' : (topic) ->

                topic.nsExtend {

                    prop1 : 2

                }, true

                assert.equal topic.prop1, 2

            teardown : ->

                delete vibe.namespace.nsDefaultContext['extendedtoplevelns']

        'Namespace#nsChildren()' :

            topic : ->

                result = namespace 'filteredtoplevelns',

                    extend :

                        numprop : 1
                        stringprop : '1'

                result

            'must not fail on filter begin explicitly defined as undefined' : (topic) ->

                cb = ->

                    topic.nsChildren(undefined)

                assert.doesNotThrow cb, TypeError

            'must fail on filter being an object without a filter function' : (topic) ->

                cb = ->

                    topic.nsChildren({})

                assert.throws cb, TypeError

            'must fail on filter being a simple type' : (topic) ->

                cb = ->

                    topic.nsChildren('filter')

                assert.throws cb, TypeError

            'must invoke the filter with both a key and a value' : (topic) ->

                cb = ->

                    topic.nsChildren (key, value) ->

                        if key is undefined

                            throw new Error 'no key provided'

                        if value is undefined

                            throw new Error 'no value provided'

                 assert.doesNotThrow cb, Error

            # test case fails due to some internal error in vows
            'skipping:must invoke filter method or function defined on object' : (topic) ->

                # skipping
                return

                invoked = false
                obj =

                    filter : (key, value) ->

                        invoked = true

                cb = ->

                    topic.nsChildren obj

                assert.doesNotThrow cb, TypeError
                assert.isTrue invoked

            'must return the filtered children as per the provided filter' : (topic) ->

                cb = ->

                    topic.nsChildren (key, value) ->

                        if 'number' == typeof value

                            return true

                        return false

                expected =

                    numprop : 1

                assert.deepEqual cb(), expected

            'must return the namespace if no filter was specified' : (topic) ->

                assert.deepEqual topic.nsChildren(), topic

            teardown : ->

                delete vibe.namespace.nsDefaultContext['filteredtoplevelns']

    .export module

