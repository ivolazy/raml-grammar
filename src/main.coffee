{typ3} = require './utils.coffee'

# Grammar representation objects
# TODO: Add required fields
class Tuple
  constructor: (@key, @value) ->
    if not @key instanceof Node && typ3(@key) != 'string'
      throw "Key: '#{JSON.stringify(key)}' of type '#{typ3(key)}' must be an string"

class Alternatives
  constructor: (@alternatives...) ->

class PrimitiveAlternatives
  constructor: (@alternatives...) ->

class Multiple
  constructor: (@element) ->

class PostposedExecution
  constructor: (@f) ->

class Node

class Markdown extends Node

class Include extends Node

class JSONSchema extends Node

class Regex extends Node

class Integer extends Node

class Boolean extends Node

class XMLSchema extends Node

class StringNode extends Node

notImplemented = () -> throw new Error('Not implemented')

class @NodeMap
  @markdown: notImplemented
  @include: notImplemented
  @jsonSchema: notImplemented
  @regex: notImplemented
  @integer: notImplemented
  @boolean: notImplemented
  @xmlSchema: notImplemented
  @stringNode: notImplemented


# primitives
markdown = new Markdown()
include = new Include()
jsonSchema = new JSONSchema()
regex = new Regex()
integer = new Integer()
boolean = new Boolean()
xmlSchema = new XMLSchema()
stringNode = new StringNode()

transversePrimitive = (nodeMap, node) ->
  if node == undefined
    throw new Error('Invalid root specified')

  switch
    when node instanceof Markdown
      nodeMap.markdown(node)
    when node instanceof Include
      nodeMap.include(node)
    when node instanceof JSONSchema
      nodeMap.jsonSchema(node)
    when node instanceof Regex
      nodeMap.regex(node)
    when node instanceof Integer
      nodeMap.integer(node)
    when node instanceof Boolean
      nodeMap.boolean(node)
    when node instanceof XMLSchema
      nodeMap.xmlSchema(node)
    when node instanceof StringNode
      nodeMap.stringNode(node)
    else
      throw 'Invalid state: type ' + typ3(root) + ' object ' + root

class TreeMap
  @alternatives: notImplemented
  @tuple: notImplemented
  @multiple: notImplemented
  @primitiveAlternatives: notImplemented
  @postponedExecution: notImplemented
  @nodeMap: notImplemented
  @string: notImplemented

transverse = (treeMap, root) ->
  if root == undefined
    throw new Error('Invalid root specified')

  switch
    when root instanceof Alternatives
      alternatives = (transverse(treeMap, alternative) for alternative in root.alternatives)
      treeMap.alternatives(root, alternatives)
    when root instanceof Tuple
      a = transverse(treeMap, root.key)
      b = transverse(treeMap, root.value)
      treeMap.tuple(root, a, b)
    when root instanceof Multiple
      m = transverse(treeMap, root.element)
      treeMap.multiple(root, m)
    when root instanceof PrimitiveAlternatives
      alternatives = (transverse(treeMap, alternative) for alternative in root.alternatives)
      treeMap.primitiveAlternatives(root, alternatives)
    when root instanceof PostposedExecution
      promise = new PostposedExecution(() -> transverse(treeMap, root.f()))
      treeMap.postponedExecution(root, promise)
    when root instanceof Node
      treeMap.node(root)
    when typ3(root) == 'string'
      treeMap.string(root)
    else
      console.log(root)
      throw new Error('Invalid state: type ' + typ3(root) + ' object ' + root)

@transverse = transverse

# Base Attributes

title = new Tuple('title',  stringNode) 
version = new Tuple('version',  stringNode) 
model = new Tuple(stringNode,  jsonSchema) 
schemas = new Tuple('schemas', new Multiple(model))
baseUri = new Tuple('baseUri',  stringNode) 

# Parameter fields

name = new Tuple('name', stringNode)
description = new Tuple('description',  stringNode)
type = new Tuple('type', new PrimitiveAlternatives('string', 'number', 'integer', 'date' ))
enum2 = new Tuple('enum', new Multiple(stringNode))
pattern = new Tuple('pattern',  regex) 
minLength = new Tuple('minLength',  integer) 
maxLength = new Tuple('maxLength',  integer) 
minimum = new Tuple('minimum',  integer) 
maximum = new Tuple('maximum',  integer) 
required = new Tuple('required',  boolean) 
d3fault = new Tuple('default',  stringNode) 
requires = new Tuple('requires',  new Multiple(stringNode)) 
provides = new Tuple('provides',  new Multiple(stringNode)) 
excludes = new Tuple('excludes',  new Multiple(stringNode)) 
parameterProperty = new Alternatives(name, description, type, enum2, pattern, minLength, 
  maxLength, maximum, minimum, required, d3fault, requires, excludes)

uriParameter = new Tuple(stringNode,  new Multiple(parameterProperty))
uriParameters = new Tuple('uriParameters',  new Multiple(uriParameter))
defaultMediaTypes = new Tuple('defaultMediaTypes',  
  new PrimitiveAlternatives(stringNode, new Multiple(stringNode)))
chapter = new Alternatives(new Tuple('title',  stringNode), new Tuple('content',  stringNode))
documentation = new Tuple('documentation',  new Multiple(chapter))
summary = new Tuple('summary',  stringNode)
example = new Tuple('example',  stringNode)

# Header

header = new Tuple(stringNode,  new Multiple(new Alternatives(parameterProperty, example)))
headers = new Tuple('headers',  new Multiple(header))

# Parameters

queryParameterDefinition = new Tuple(stringNode,  
  new Multiple(new Alternatives(parameterProperty, example)))
queryParameters = new Tuple('queryParameters',  new Multiple(queryParameterDefinition))
formParameters = new Tuple('formParameters',  
  new Multiple(new Alternatives(parameterProperty, example)))


# Body and MIME Type

bodySchema = new Tuple('schema',  new PrimitiveAlternatives(xmlSchema, jsonSchema))
mimeTypeParameters = new Multiple(new Alternatives(bodySchema, example))
mimeType = new Alternatives(new Tuple('application/x-www-form-urlencoded', 
  new Multiple(formParameters)), new Tuple('multipart/form-data',  new Multiple(formParameters)),  
  new Tuple(stringNode,  new Multiple(mimeTypeParameters)))
body = new Tuple('body',  new Multiple(mimeType))

# Responses

responseCode = new Tuple(integer, new Multiple(integer), 
  new Multiple(new Alternatives(body, description)))
responses = new Tuple('responses',  new Multiple(responseCode))

# Actions

actionDefinition = new Alternatives(summary, description, headers, queryParameters, 
  body, responses)
action = new Alternatives(((new Tuple(actionName, new Multiple(actionDefinition))) for actionName in ['get', 'post', 'put', 'delete', 'head', 'path', 'options'])...)

# Use

use = new Tuple('use',  new Multiple(stringNode))

# Resource

resourceDefinition = new Alternatives(name, action, use, 
  new Tuple(stringNode, new PostposedExecution(() -> resourceDefinition)))
resource = new Tuple(stringNode,  new Multiple(resourceDefinition))

# Traits

traitDefinition = new Tuple(stringNode,  new Multiple(
  new Alternatives(description, provides, requires)))
trait = new Tuple('traits',  traitDefinition)
traits = new Multiple(trait)

# Root Element

rootElement = new Alternatives(title, version, schemas, baseUri, uriParameters, 
  defaultMediaTypes, documentation, resource, traits)
root = new Multiple(rootElement) 

@root = root
@transversePrimitive = transversePrimitive
@TreeMap = TreeMap

# Categories

class Category
  constructor: (@name, @elements) ->
