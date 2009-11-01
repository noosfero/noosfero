def find_test_smells(id, title, pattern)
  full_id = 'test:smells:' + id
  task full_id do
    system("
      (
        echo '########################################################'
        echo '# #{title}'
        echo '########################################################'
        echo
        ack-grep --group --color '#{pattern}' test/unit/ test/functional/ test/integration/
      ) | less -R
    ")
  end
  task 'test:smells' => full_id
end

find_test_smells 'dbhits', "Full database hits (they are probably unecessary)", '\.create'
find_test_smells 'constants', 'Probably unecessary contants for creating objects', "create_user.*password"
