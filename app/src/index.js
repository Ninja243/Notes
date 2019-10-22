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
        link="https://jsonplaceholder.typicode.com/users"
        render={({ list, isLoading, error }) => (
          <div>
            <h1>Notes</h1>
            <hr></hr>
            {error ? <p>{error.message}</p> : null}
            {isLoading ? (
              <h2>Loading...</h2>
            ) : (
              <ul>{list.map(user => <li key={user.id}>{user.name}</li>)}</ul>
            )}
          </div>
        )}
      />
    );
  }
  
  // class App extends React.Component {
  //   render() {
      // return (
      //   <Wrapper
      //     link="https://jsonplaceholder.typicode.com/users"
      //     render={({ list, isLoading, error }) => (
      //       <div>
      //         <h2>Random Users</h2>
      //         {error ? <p>{error.message}</p> : null}
      //         {isLoading ? (
      //           <h2>Loading...</h2>
      //         ) : (
      //           <ul>{list.map(user => <li key={user.id}>{user.name}</li>)}</ul>
      //         )}
      //       </div>
      //     )}
      //   />
      // );
  //   }
  // }
  
  
  ReactDOM.render(<App />, document.getElementById("root"));