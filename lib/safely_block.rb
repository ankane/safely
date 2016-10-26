require "safely/core"

Object.send :include, Safely::Methods
Class.send :include, Safely::ClassMethods
Module.send :include, Safely::ClassMethods
