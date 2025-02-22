module Plotting

export nameplot
export nameplot!

# TODO: can we export a plot method if we use MakieCore? (Makie as extension)
export trajectoryplot

# TODO: where do docstrings go?

function nameplot end
function nameplot! end
function trajectoryplot end

# TODO: Could add error hint for missing package per MakiePkgExtTest

end