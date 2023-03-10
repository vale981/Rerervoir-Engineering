using DrWatson
@quickactivate "Reservoir Engineering"

# Here you may include files from the source directory
include(srcdir("Looping"))

println(
"""
Currently active project is: $(projectname())

Path of active project: $(projectdir())

Have fun with your new project!

You can help us improve DrWatson by opening
issues on GitHub, submitting feature requests,
or even opening your own Pull Requests!
"""
)
