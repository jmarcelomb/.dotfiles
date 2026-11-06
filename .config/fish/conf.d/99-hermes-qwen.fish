# Fast model access for Hermes
# Pattern: h<model> = chat, h<model>t = TUI (--tui)
# hq / hqt   = local qwen35 (MLX Qwen3.5-9B)
# hf / hft   = flash (OpenRouter preset: DeepSeek V4.1 Flash 1017 via DeepInfra/Morph)
# hgf / hgft = gflash (zai glm-5.3-flash)
# hg / hgt   = glm (zai glm-5.3)
# ht         = plain hermes in the TUI, default model
# hqset      = set qwen35 as the persistent default model in config
function hq --description 'hermes chat on local qwen35'
    hermes chat --model qwen35 $argv
end

function hqt --description 'hermes TUI chat on local qwen35'
    hermes chat --model qwen35 --tui $argv
end

function hf --description 'hermes chat on DeepSeek flash (OpenRouter preset)'
    hermes chat --model flash $argv
end

function hft --description 'hermes TUI chat on DeepSeek flash (OpenRouter preset)'
    hermes chat --model flash --tui $argv
end

function hgf --description 'hermes chat on glm-5.3-flash'
    hermes chat --model gflash $argv
end

function hgft --description 'hermes TUI chat on glm-5.3-flash'
    hermes chat --model gflash --tui $argv
end

function hg --description 'hermes chat on glm-5.3'
    hermes chat --model glm $argv
end

function hgt --description 'hermes TUI chat on glm-5.3'
    hermes chat --model glm --tui $argv
end

function ht --description 'hermes TUI on the default model'
    hermes --tui $argv
end

function hqset --description 'set qwen35 as the default model in config'
    hermes config set model.default qwen35
end
