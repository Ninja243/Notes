import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';

function notes1() {
    return (
        <div>
            <h1>Welcome to Noter!</h1>
            <p>The notebook application</p>
        </div>
    )
}

ReactDOM.render(<notes1 />, document.getElementById("root"))


