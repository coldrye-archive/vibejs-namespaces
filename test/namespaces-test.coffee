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



# add some required assertion macros

assert.isFrozen = (obj, message = null) ->

    if obj is undefined or obj is null

        throw new TypeError 'obj is null or undefined'

    if not Object.isFrozen obj

        assert.fail null, null, message || "expected obj to be frozen but was not", "isFrozen", assert.isFrozen


assert.isNotFrozen = (obj, message = null) ->

    if obj is undefined or obj is null

        throw new TypeError 'obj is null or undefined'

    if Object.isFrozen obj

        assert.fail null, null, message || "expected obj to not be frozen but was", "isNotFrozen", assert.isNotFrozen


assert.isNotConfigurable = (obj, key, message = null) ->

    if obj is undefined or obj is null

        throw new TypeError 'obj is null or undefined'

    if key is undefined or key is null

        throw new TypeError 'key is null or undefined'

    assert.isDefined obj, key

    oval = obj[key]
    delete obj[key]

    try

        assert.strictEqual obj[key], oval, message || "expected obj.key to be not configurable.", "isNotConfigurable", assert.isNotConfigurable

    finally

        obj[key] = oval


vows
    .describe 'vibejs.lang'
    .addBatch

        'vibejs.lang' :

            'must have a nsDefaultContext property' :

                'that is enumerable' : ->

                    assert.isEnumerable vibejs.lang, 'nsDefaultContext'

                'that is not configurable' : ->

                    assert.isNotConfigurable vibejs.lang, 'nsDefaultContext'

            'must have a namespace property' :

                'that is enumerable' : ->

                    assert.isEnumerable vibejs.lang, 'namespace'

                'that is not configurable' : ->

                    assert.isNotConfigurable vibejs.lang, 'namespace'

                'that is a function' : ->

                    assert.isFunction vibejs.lang.namespace

            'must have a Namespace property' :

                'that is enumerable' : ->

                    assert.isEnumerable vibejs.lang, 'Namespace'

                'that is not configurable' : ->

                    assert.isNotConfigurable vibejs.lang, 'Namespace'

                'that is a function' : ->

                    assert.isFunction vibejs.lang.Namespace

        'NS_QNAME_RE' :

            topic : ->

                vibejs.lang.constants.NS_QNAME_RE

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

            'must be equal to window (browser) or global (node)' : ->

                assert.strictEqual vibejs.lang.nsDefaultContext, if window? then window else global

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

                assert.doesNotThrow cb
                assert.isTrue vibejs.lang.nsDefaultContext['toplevelns'] instanceof vibejs.lang.Namespace
                assert.deepEqual vibejs.lang.nsDefaultContext['toplevelns'], {}

                delete vibejs.lang.nsDefaultContext['toplevelns']

            'must fall back to nsDefaultContext on undefined context' : ->

                cb = ->

                    namespace 'toplevelns', undefined

                assert.doesNotThrow cb
                assert.isTrue vibejs.lang.nsDefaultContext['toplevelns'] instanceof vibejs.lang.Namespace
                assert.deepEqual vibejs.lang.nsDefaultContext['toplevelns'], {}

                delete vibejs.lang.nsDefaultContext['toplevelns']

            'must return declared namespace' : ->

                top = namespace 'toplevelns'
                assert.isNotNull top
                assert.deepEqual vibejs.lang.nsDefaultContext['toplevelns'], top

                delete vibejs.lang.nsDefaultContext['toplevelns']

            'must return declared sub namespace' : ->

                sub = namespace 'toplevelns.sub'
                assert.isNotNull sub
                assert.deepEqual vibejs.lang.nsDefaultContext['toplevelns'].sub, sub

                delete vibejs.lang.nsDefaultContext['toplevelns']

            'declared namespace must be a defined property of its context' : ->

                namespace 'toplevelns'
                assert.isTrue vibejs.lang.nsDefaultContext.hasOwnProperty 'toplevelns'

                delete vibejs.lang.nsDefaultContext['toplevelns']

            'declared namespace must be an enumerable property of its context' : ->

                namespace 'toplevelns'
                found = false
                assert.isEnumerable vibejs.lang.nsDefaultContext, 'toplevelns'

                delete vibejs.lang.nsDefaultContext['toplevelns']

            'declared namespace must be a deletable property of its context' : ->

                namespace 'toplevelns'
                delete vibejs.lang.nsDefaultContext['toplevelns']

                assert.isUndefined vibejs.lang.nsDefaultContext['toplevelns']

            'must create hierarchy of namespaces from a qualified identifier' : ->

                sub = namespace 'toplevelns.sub'
                top = vibejs.lang.nsDefaultContext['toplevelns']

                assert.deepEqual top, { sub : sub }

                delete vibejs.lang.nsDefaultContext['toplevelns']

            'must not redeclare existing namespace' : ->

                top = namespace 'toplevelns'
                top.a = 1
                sub = namespace 'toplevelns.sub'

                assert.deepEqual top, { a: 1, sub : {} }

                delete vibejs.lang.nsDefaultContext['toplevelns']

            'must fail when encountering non namespace and not redeclare existing key' : ->

                top = namespace 'toplevelns'
                top.sub = 1

                cb = ->

                    namespace 'toplevelns.sub'

                assert.throws cb, Error

                delete vibejs.lang.nsDefaultContext['toplevelns']

        'Namespace' :

            'must not be instantiated directly' : ->

                cb = ->

                    new vibejs.lang.Namespace

                assert.throws cb, TypeError

        'Namespace instances must have default properties and methods that are not enumerable' :

            'nsLocalName' : ->

                top = namespace 'toplevelns'

                assert.isDefined top, 'nsLocalName'
                assert.isNotEnumerable top, 'nsLocalName'
                assert.equal top.nsLocalName, 'toplevelns'

                delete vibejs.lang.nsDefaultContext['toplevelns']

            'nsQualifiedName' : ->

                sub = namespace 'toplevelns.sub'

                assert.isDefined sub, 'nsQualifiedName'
                assert.isNotEnumerable sub, 'nsQualifiedName'
                assert.equal sub.nsQualifiedName, 'toplevelns.sub'

                delete vibejs.lang.nsDefaultContext['toplevelns']

            'nsParent' : ->

                sub = namespace 'toplevelns.sub'
                top = vibejs.lang.nsDefaultContext['toplevelns']

                assert.isDefined top, 'nsParent'
                assert.isNotEnumerable top, 'nsParent'
                assert.deepEqual top, sub.nsParent

                delete vibejs.lang.nsDefaultContext['toplevelns']

            'nsChildren' : ->

                top = namespace 'toplevelns'

                assert.isDefined top, 'nsChildren'
                assert.isNotEnumerable top, 'nsChildren'
                assert.isFunction top.nsChildren

                delete vibejs.lang.nsDefaultContext['toplevelns']

            'nsFrozen' : ->

                top = namespace 'toplevelns'

                assert.isDefined top, 'nsFrozen'
                assert.isNotEnumerable top, 'nsFrozen'
                assert.isFalse top.nsFrozen

                delete vibejs.lang.nsDefaultContext['toplevelns']

            'nsFreeze' : ->

                top = namespace 'toplevelns'

                assert.isDefined top, 'nsFreeze'
                assert.isNotEnumerable top, 'nsFreeze'
                assert.isFunction top.nsFreeze

                delete vibejs.lang.nsDefaultContext['toplevelns']

            'nsExtend' : ->

                top = namespace 'toplevelns'

                assert.isDefined top, 'nsExtend'
                assert.isNotEnumerable top, 'nsExtend'
                assert.isFunction top.nsExtend

                delete vibejs.lang.nsDefaultContext['toplevelns']

            '_logger' : ->

                top = namespace 'toplevelns'

                assert.isNotEnumerable top, '_logger'

                delete vibejs.lang.nsDefaultContext['toplevelns']

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

                delete vibejs.lang.nsDefaultContext['frozentoplevelns']

        'Namespace#nsExtend()' :

            topic : ->

                namespace 'extendedtoplevelns',

                    extend :

                        prop1 : 1

            'by default must not override existing properties' : (topic) ->

                topic.nsExtend

                    extend :

                        prop1 : 2

                assert.equal topic.prop1, 1

            'must override existing properties when told to do so' : (topic) ->

                topic.nsExtend

                    override : true

                    extend :

                        prop1 : 2

                assert.equal topic.prop1, 2

            teardown : ->

                delete vibejs.lang.nsDefaultContext['extendedtoplevelns']

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

                assert.doesNotThrow cb

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

                 assert.doesNotThrow cb

            'must invoke filter method or function defined on object' : (topic) ->

                invoked = false
                obj =

                    filter : (key, value) ->

                        invoked = true

                cb = ->

                    topic.nsChildren obj

                assert.doesNotThrow cb
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

                delete vibejs.lang.nsDefaultContext['filteredtoplevelns']

    .export module
