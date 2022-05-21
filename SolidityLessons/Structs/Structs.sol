// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Todos {

    struct Todo {
        string text;
        bool completed;
    }

    Todo[] public todos;

    function create(string memory _text) public {
        todos.push(Todo(_text, false));

       /* Todo({
            text: _text,
            completed: false
        })

        Todo memory todo;
        todo.text = _text;
        // todo.completed = false; */
    }

    function get(uint _index) public view returns (string memory, bool) {
        Todo storage todo = todos[_index];
        return(todo.text, todo.completed);
    }

    function get_2(uint _index) public view returns(string memory text, bool completed) {
        Todo storage todo = todos[_index];
        return(todo.text, todo.completed);
    }

    function updateText(uint _index, string memory _text) public {
        Todo storage todo = todos[_index];
        todo.text = _text;
    }

    function toggleCompleted(uint _index) public {
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
    }
}