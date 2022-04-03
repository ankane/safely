require "safely/core"

Object.include Safely::Methods
Object.send :private, :safely, :yolo

Enumerator.include Safely::EnumeratorMethods
