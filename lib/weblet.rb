#!/usr/bin/env ruby

# file: weblet.rb

require 'rexle'
require 'rxfreader'


class WebletBuilder

  def initialize(s, marker: nil, debug: false)

    @marker, @debug = marker, debug

    s.strip!

    # the default marker is the hash symbol (#) but the client can set their
    # own marker by simply using their custom symbol in the 1st line of input
    @marker ||= s[0]

    a = scan(s.strip)
    puts 'a: ' + a.inspect if @debug

    @a = build(a)
    @a.unshift *['weblet', {}, '']

  end

  def to_a()
    @a
  end

  private

  def scan(s, indent=0)

    a = s.split(/(?=^#{('  ' * indent) + @marker})/)
    return a unless a.length > 1

    a.map {|x| scan(x, indent+1)}

  end

  def build(a)

    puts 'a: ' + a.inspect if @debug

    a.map do |x|

      puts 'x: ' + x.inspect if @debug

      if x.is_a? String then

        head, body = x.split("\n", 2)
        puts 'head: ' + head.inspect if @debug
        puts 'body: ' + body.inspect if @debug
        puts 'marker: ' + @marker.inspect if @debug

        [:node, {id: head[/#{@marker}(\w+)/,1]}, '',['![', {}, body.strip]]

      elsif x[0].is_a? String

        head, body = x[0].split("\n", 2)
        puts 'body: ' + body.inspect if @debug
        puts 'marker: ' + @marker.inspect if @debug

        [:node, {id: head[/#{@marker}(\w+)/,1]}, '',['![', {}, body.strip]]

      elsif x[0] and x[0].is_a? Array

        head, body = x[0][0].split("\n", 2)
        [:node, {id: head[/#{@marker}(\w+)/,1]}, '', \
         ['![', {}, body.to_s.strip], *build(x[1..-1])]

      end

    end

  end
end


class Weblet

  def initialize(raws, marker: nil, debug: false)

    @debug = debug

    s, _ = RXFReader.read(raws.strip)

    obj = s[0] == '<' ? s : WebletBuilder.new(s, marker: marker, \
                                                    debug: debug).to_a
    puts 'obj: ' + obj.inspect if @debug
    @doc = Rexle.new(obj)
    @h = scan @doc.root
    @kvp = scan2keypair(@h).to_h

  end

  def [](key)
    @kvp[key.to_s]
  end

  def []=(key, value)
    @kvp[key.to_s] = value
  end

  def to_h()
    @h
  end

  # key-value pair
  def to_kvp()
    @kvp
  end

  def to_outline()
    treeize(scan_h(@h))
  end

  def to_xml()
    @doc.root.xml pretty: true
  end

  def render(rawkey, bindingx=nil)

    key = rawkey.to_s
    return unless @kvp.has_key?(key)

    # check for interpolated substitution tags e.g/ <:card/svg/link>
    r = @kvp[key].gsub(/<:([^>]+)>/) {|x| self.render($1) }

    eval('%Q(' + r + ')', bindingx)

  end

  private

  def scan(node)

    a = node.elements.map do |e|

      nodes = e.xpath('node')

      r = if nodes.any? then

        r2 = scan(e)
        e.cdatas.any? ? [e.cdatas.join(), r2] : r2

      else
        e.cdatas.join()
      end

      [e.attributes[:id].to_sym, r]

    end.to_h

  end

  def scan_h(h)

    a = h.map do |key, value|
      value.is_a?(Array) ? [key, scan_h(value.last)] : [key]
    end

  end

  def treeize(a, indent=-2)

    indent += 1
    a.map  do |x|

      if x.is_a? Symbol then
        (' ' * indent) + x.to_s
      else
        treeize(x, indent)
      end

    end.join("\n")

  end

  def scan2keypair(h, trail=nil)

    h.inject([]) do |r,x|

      if x.last.is_a? String then

        key, val = x

        new_key = if r.last and r.last.first.length > 0 then
          key.to_s
        else
          key.to_s
        end

        r << [[trail, new_key].compact.join('/'), val]

      else

        new_key = x.first.to_s
        r << [new_key, x.last.first]
        r.concat scan2keypair(x.last.last, [trail, new_key].compact.join('/'))

      end

    end

  end

end
