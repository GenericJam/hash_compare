defmodule HashCompareTest do
  use ExUnit.Case

  test "basic matching hash" do
    hash1 = %{
      "fruit" => "Apple",
      "size" => "Large",
      "color" => "Red"
    }

    hash2 = %{
      "fruit" => "Apple",
      "size" => "Large",
      "color" => "Red"
    }

    assert "Matching hashes" == HashCompare.compare_hash(hash1, hash2)
  end

  test "basic nonmatching hash" do
    hash1 = %{
      "fruit" => "Orange",
      "size" => "Large",
      "color" => "Orange"
    }

    hash2 = %{
      "fruit" => "Apple",
      "size" => "Large",
      "color" => "Red"
    }

    assert "Depth 0, position 0 difference on key: \"color\" [\"Orange\", \"Red\"] \nDepth 0, position 1 difference on key: \"fruit\" [\"Orange\", \"Apple\"] \n" ==
             HashCompare.compare_hash(hash1, hash2)
  end

  test "list hash" do
    hash1 = [1, 3, 3, 3, 4]

    hash2 = [1, 2, 2, 3, 4, 5]

    assert "Depth 0, position 1 hash 2 extra [2, 2] \nDepth 0, position 3 hash 2 extra [3, 3] \nDepth 0, position 5 hash 2 extra [5] \n" ==
             HashCompare.compare_hash(hash1, hash2)
  end

  test "deep map with lists matches" do
    hash1 = %{
      "quiz" => %{
        "sport" => %{
          "q1" => %{
            "question" => "Which one is correct team name in NBA?",
            "options" => [
              "New York Bulls",
              "Los Angeles Kings",
              "Golden State Warriors",
              "Houston Rockets"
            ],
            "answer" => "Houston Rockets"
          }
        },
        "maths" => %{
          "q1" => %{
            "question" => "5 + 7 = ?",
            "options" => [
              "10",
              "11",
              "12",
              "13"
            ],
            "answer" => "12"
          },
          "q2" => %{
            "question" => "12 - 8 = ?",
            "options" => [
              "1",
              "2",
              "3",
              "4"
            ],
            "answer" => "4"
          }
        }
      }
    }

    hash2 = %{
      "quiz" => %{
        "sport" => %{
          "q1" => %{
            "question" => "Which one is correct team name in NBA?",
            "options" => [
              "New York Bulls",
              "Los Angeles Kings",
              "Golden State Warriors",
              "Houston Rockets"
            ],
            "answer" => "Houston Rockets"
          }
        },
        "maths" => %{
          "q1" => %{
            "question" => "5 + 7 = ?",
            "options" => [
              "10",
              "11",
              "12",
              "13"
            ],
            "answer" => "12"
          },
          "q2" => %{
            "question" => "12 - 8 = ?",
            "options" => [
              "1",
              "2",
              "3",
              "4"
            ],
            "answer" => "4"
          }
        }
      }
    }

    assert "Matching hashes" == HashCompare.compare_hash(hash1, hash2)
  end

  test "deep map with lists nonmatches to various depths" do
    hash1 = %{
      "quiz" => %{
        "spourt" => %{
          "q2" => %{
            "question" => "Which one is correct team name in NBA?",
            "options" => [
              "New York Bulls",
              "Los Angeles Kings",
              "Golden State Warriors",
              "Houston Rockets"
            ],
            "answer" => "Houston Rockets"
          }
        },
        "maths" => %{
          "q1" => %{
            "question" => "5 + 7 = ?",
            "options" => [
              "10",
              "11",
              "13"
            ],
            "answer" => "12"
          },
          "q2" => %{
            "question" => "12 - 8 = ?",
            "options" => [
              "1",
              "2",
              "3",
              "4"
            ],
            "answer" => "4"
          }
        }
      }
    }

    hash2 = %{
      "quiz" => %{
        "sport" => %{
          "q1" => %{
            "question" => "Which one is correct team name in NHL?",
            "options" => [
              "New York Bulls",
              "Los Angeles Kings",
              "Houston Rockets"
            ],
            "answer" => "Houston Rockets"
          }
        },
        "maths" => %{
          "q1" => %{
            "question" => "5 + 7 = ?",
            "options" => [
              "10",
              "11",
              "12",
              "13"
            ],
            "answer" => "12"
          },
          "q2" => %{
            "question" => "12 - 8 = ?",
            "options" => [
              "1",
              "2",
              "3",
              "4"
            ],
            "answer" => "4"
          }
        }
      }
    }

    assert "Matching hashes" == HashCompare.compare_hash(hash1, hash2, 1)

    assert "Depth 1, position 1 different keys: [\"spourt\", \"sport\"]} \n" ==
             HashCompare.compare_hash(hash1, hash2, 2)

    assert "Depth 1, position 1 different keys: [\"spourt\", \"sport\"]} \nDepth 2, position 0 different keys: [\"q2\", \"q1\"]} \nDepth 3, position 2 difference on key: \"question\" [\"Which one is correct team name in NBA?\", \"Which one is correct team name in NHL?\"] \n" ==
             HashCompare.compare_hash(hash1, hash2, 4)

    assert "Depth 4, position 2 hash 2 extra [\"12\"] \nDepth 1, position 1 different keys: [\"spourt\", \"sport\"]} \nDepth 2, position 0 different keys: [\"q2\", \"q1\"]} \nDepth 4, position 2 hash 2 extra [\"Golden State Warriors\"] \nDepth 3, position 2 difference on key: \"question\" [\"Which one is correct team name in NBA?\", \"Which one is correct team name in NHL?\"] \n" ==
             HashCompare.compare_hash(hash1, hash2)
  end
end
