#!/usr/bin/env ruby

# file: weblet.rb

require 'rexle'
require 'rxfhelper'


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
    
    s, _ = RXFHelper.read(raws.strip)

    obj = s[0] == '<' ? s : WebletBuilder.new(s, marker: marker, \
                                                    debug: debug).to_a
    puts 'obj: ' + obj.inspect if @debug
    @doc = Rexle.new(obj)
    @h = scan @doc.root

  end

  def to_h()
    @h
  end
  
  def to_outline()
    treeize(scan_h(@h))
  end
  
  def to_xml()
    @doc.root.xml pretty: true
  end

  def render(*args)
    
    b = args.pop if args.last.is_a? Binding
    
    if args.first.is_a? String then
      path = args.first.split('/').map(&:to_sym)
    else
      path = *args.flatten(1)
    end

    #r = @h.dig *path
    r = digx(@h, path)
    
    # check for interpolated substitution tags e.g/ <:card/svg/link>
    r.gsub!(/<:([^>]+)>/) {|x| self.render($1) } if r
    
    puts 'r: ' + r.inspect if @debug
    
    if r.nil? then
      found = @doc.root.element("//node[@id='#{path.join}']")
      r = found.cdatas.join if found
    end
    
    eval('%Q(' + r + ')', b) if r

  end

  private
  
  def digx(obj, a)

    h = obj.is_a?(Array) ? obj.last : obj

    r = h.dig(a.shift)

    if a.any? then
      digx(r, a)
    else
      r.is_a?(Array) ? r.first : r
    end

  end  

  def scan(node)

    a = node.elements.map do |e|
      
      puts 'e: ' + e.inspect if @debug

      nodes = e.xpath('node')
      
      puts 'nodes: ' + nodes.inspect if @debug
      
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
  
  
end
