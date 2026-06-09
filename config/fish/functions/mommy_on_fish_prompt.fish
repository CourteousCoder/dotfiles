function mommy_on_fish_prompt --on-event fish_prompt
    mommy.py "$status" | lolcat > /dev/stderr
end
