import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import axios from 'axios';

class Wrapper extends React.Component {
    state = {
      isLoading: true,
      error: null,
      list: []
    };
  
    fetchData() {
      axios.get(this.props.link)
        .then((response) => {
          this.setState({
            list: response.data,
            isLoading: false
          });
      })
      .catch(error => this.setState({ error, isLoading: false }));
    }
  
    componentDidMount() {
      this.setState({ isLoading: true }, this.fetchData);
    }
  
    render() {
      return this.props.render(this.state);
    }
  }

  const App = () => {
    return (
      <Wrapper
      //TODO the link needs to change to http://localhost:whatever visit typicode.com to see what json i used as an example
        link="https://jsonplaceholder.typicode.com/users"
        render={({ list, isLoading, error }) => (
          <div>
            <h1>Notes</h1>
            <hr />
            <br />
            <div className="align-center">
                <button type="button">Add Note</button> <br />
            </div>
            <input type="radio" name="notes" value="today" /><text>    Notes of today</text><br />
            <input type="radio" name="notes" value="today" /><text>    Notes of this month</text><br />
            <input type="radio" name="notes" value="today" /><text>    Notes of this year</text><br />
            {error ? <p>{error.message}</p> : null}
            {isLoading ? (
              <h2>Loading...</h2>
            ) : (
                //TODO the info in the map should change from user data to note data
                //info that needs to change: 
                //user needs to be note. 
                //li key={user.id} needs to be li key={hash}. 
                //Date needs to be {note.date}. 
                //Date needs to be the time the note was posted
                //{user.name} needs to be {note.note}
              <ul>{list.map(user => <li key={user.id}>
                  <div className="header"><button type="button">x</button></div>
                  <div className="note">
                      <h3>{user.company.name}</h3><hr />
                      <p>Created: Date @Time</p><br />
                      <p>{user.company.catchPhrase}</p>
                  </div>
                </li>)}</ul>
            )}
          </div>
        )}
      />
    );
  }
  
  
  ReactDOM.render(<App />, document.getElementById("root"));