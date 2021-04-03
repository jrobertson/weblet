# Weblet: Content is now enclosed within a CDATA element

    require 'weblet'

    s3 = %q(
    #fun
    <p>hut</p>

    #good
    <p>star #{s2}</p>

    #saturday
    It's sunny!

    #svg
      #reply

    <svg>
    i like that #{s2}
    </svg>

      #favorite
    <p>231</p>
    )


    s2 = 'tree'

    w = Weblet.new(s3, binding, debug: true)

    puts w.render('svg/reply') #=> <svg>\n  i like that tree ...
    puts w.render(:saturday)   #=> It's sunny!  
    puts w.render(:reply)      #=> <svg>\n  i like that tree ...

    puts w.to_xml

Output:
<pre>
&lt;weblet&gt;
  &lt;node id='fun'&gt;&lt;![CDATA[&lt;p&gt;hut&lt;/p&gt;]]&gt;&lt;/node&gt;
  &lt;node id='good'&gt;&lt;![CDATA[&lt;p&gt;star #{s2}&lt;/p&gt;]]&gt;&lt;/node&gt;
  &lt;node id='saturday'&gt;&lt;![CDATA[It's sunny!]]&gt;&lt;/node&gt;
  &lt;node id='svg'&gt;
    &lt;node id='reply'&gt;&lt;![CDATA[&lt;svg&gt;
i like that #{s2}
&lt;/svg&gt;]]&gt;&lt;/node&gt;
    &lt;node id='favorite'&gt;&lt;![CDATA[&lt;p&gt;231&lt;/p&gt;]]&gt;&lt;/node&gt;
  &lt;/node&gt;
&lt;/weblet&gt;
</pre>

weblet

----------------------------

# Introducing the Weblet gem

    require 'weblet'

    s3 = %q(
    #fun
    <p>hut</p>

    #good
    <p>star #{s2}</p>

    #svg
      #reply

    <svg>
    i like that #{s2}
    </svg>

      #favorite
    <p>231</p>
    )


    s2 = 'tree'

    w = Weblet.new(s3, binding)
    puts w.render('svg/reply')

Output:
<pre>
&lt;svg&gt;
i like that tree
&lt;/svg&gt;
</pre>

A slim-like template is used to store the HTML templates which are used by the Weblet gem to render the output.

## Resources

* weblet https://rubygems.org/gems/weblet

weblet template html builder weblit weblets weblits
