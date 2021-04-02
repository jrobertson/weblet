#!/usr/bin/env ruby

# file: weblet.rb

require 'rexle'


class WebletBuilder

  def initialize(s)

    @a = build(scan(s.strip))
    @a.unshift *['weblet', {}, '']
  
  end

  def to_a()
    @a
  end

  private

  def scan(s, indent=0)

    a = s.split(/(?=^#{'  ' * indent}#)/)
    return a unless a.length > 1

    a.map {|x| scan(x, indent+1)}
    
  end

  def build(a)

    a.map do |x|

      if x.is_a? String then
        head, body = x.split("\n",2)
        [:node, {id: head[/#(\w+)/,1]}, body.strip]
      else
        x.flatten!(1)
        head, body = x.shift.split("\n",2)
        [:node, {id: head[/#(\w+)/,1].rstrip}, body.rstrip, *build(x)]
      end
      
    end

  end
end


class Weblet

  def initialize(raws, b)

    raws.strip!
    obj = raws[0] == '<' ? raws : WebletBuilder.new(raws).to_a
    doc = Rexle.new(obj)
    @h = scan doc.root
    @b = b

  end

  def to_h()
    @h
  end

  def render(*args)
    
    if args.first.is_a? String then
      path = args.first.split('/',2).map(&:to_sym)
    else
      path = *args.flatten(1)
    end

    r = @h.dig *path
    eval('%Q(' + r + ')', @b) if r

  end

  private

  def scan(node)

    a = node.elements.map do |e|

      nodes = e.xpath('node')

      r = nodes.any? ? scan(e) : e.children.join()

      [e.attributes[:id].to_sym, r]
      
    end.to_h
    
  end
end
