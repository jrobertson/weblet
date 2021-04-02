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
