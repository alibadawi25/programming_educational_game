extends Node

var levels = [
	{
		"id": 1,
		"title": "Print \"Hello World\"!",
		"description": "Write a code that outputs the sentence \"Hello World\"",
		"test_cases":[],
		"expected_outputs": "Hello World",
		"is_solved": false,
		"outcome": 5 
	},
	{
		"id": 2,
		"title": "Recieve an input and print it!",
		"description": "Write a code that accepts an input string and print it\n\nExample:\n-------------------\n\nInput:Hello World\nOutput:Hello World",
		"test_cases": [
			["Hello World"],
			["Love you"]
		],
		"expected_outputs": [
			"Hello World",
			"Love you"
		],
		"is_solved": false,
		"outcome": 10
	},
	{
		"id": 3,
		"title": "Add 2 numbers",
		"description": "Write a code that recieves 2 number inputs, add them and print them\n\nExample:\n-------------------\n\nInput: 4 6\nOutput: 10",
		"test_cases": [
			["3", "5"],
			["13", "-4"]
		],
		"expected_outputs": [
			"8",
			"9"
		],
		"is_solved": false,
		"outcome": 15
	},
	{
		"id": 4,
		"title": "Identical Twins Problem",
		"description": "You will recieve two strings and you should check if they're identical or not!\n\nExample:\n-------------------\n\nInput: Ali Ali\nOutput: True",
		"test_cases": [
			["Ali", "Ali"],
			["Hello ", "Hello"],
			["lol", "lool"],
			["lo", "lol"]
		],
		"expected_outputs": [
			"True",
			"False",
			"False",
			"False"
		],
		"is_solved": false,
		"outcome": 15
	},
	{
		"id": 5,
		"title": "Numbers in Battle: Even or Odd?",
		"description": "In Numeria Kingdom, the Evenites and Oddites had long been at war. Tired of the chaos, King Evenius declared that only even numbers would be allowed to live in the kingdom. Odd numbers must be cast out forever.\n\nYour task is to check if a number is even; if it is, it stays, else it is banished.\n\nObjective: Write a program to check if a number is even or odd; output \"True\" if even.\n\nExample:\n-------------------\nInput: 6\nOutput: \"True\"",
		"test_cases": [
			[6],
			[7],
			[10],
			[13],
			[8],
			[11],
			[0],
			[-2],
			[-3]
		],
		"expected_outputs": [
			"True",
			"False",
			"True",
			"False",
			"True",
			"False",
			"True",
			"True",
			"False"
		],
		"is_solved": false,
		"outcome": 20
	},
		{
		"id": 6,
		"title": "Magic Words: Palindrome",
		"description": "In the mystical land of Lexiconia, ancient magic was hidden within words. The most powerful magic was known as the Palindrome Charm, a spell that only worked on words that read the same forwards and backwards.

		Your task is to find out if a word holds this magic. If the word is a palindrome, the magic is unlocked. If not, the spell fades.

		Objective: Write a program to check if a word is a palindrome. If it is, output \"True.\"

		Example:
		Input: \"racecar\"
		Output: \"True\"",
		"test_cases": [
			["racecar"],
			["level"],
			["hello"],
			["madam"],
			["world"],
			["radar"],
			["civic"],
			["python"],
			["noon"]
		],
		"expected_outputs": [
			"True",
			"True",
			"False",
			"True",
			"False",
			"True",
			"True",
			"False",
			"True"
		],
		"is_solved": false,
		"outcome": 20
	}
]

