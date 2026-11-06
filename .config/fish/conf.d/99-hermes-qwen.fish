# Fast model access for Hermes
# hq  = chat on local qwen35 (MLX Qwen3.5-9B)
# hf  = chat on flash (zai glm-5.3-flash)
# hb  = chat on big (zai glm-5.3)
# *t variants launch the TUI (--tui)
# hqset = set qwen35 as the persistent default model in config
function hq --description 'hermes chat on local qwen35'
    hermes chat --model qwen35 $argv
end

function hqt --description 'hermes TUI chat on local qwen35'
    hermes chat --model qwen35 --tui $argv
end

function hf --description 'hermes chat on glm-5.3-flash'
    hermes chat --model flash $argv
end

function hft --description 'hermes TUI chat on glm-5.3-flash'
    hermes chat --model flash --tui $argv
end

function hb --description 'hermes chat on glm-5.3'
    hermes chat --model big $argv
end

function hbt --description 'hermes TUI chat on glm-5.3'
    hermes chat --model big --tui $argv
end

# ht  = plain hermes, but in the TUI
function ht --description 'hermes TUI on the default model'
    hermes --tui $argv
end

function hqset --description 'set qwen35 as the default model in config'
    hermes config set model.default qwen35
end
