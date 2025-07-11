import { useState } from 'react';

function App() {
  const [greeting, setGreeting] = useState('');

  function handleSubmit(event:any) {
    event.preventDefault();
    const name = event.target.elements.name.value;
    /*chama_app_backend.greet(name).then((greeting:string) => {
      setGreeting(greeting);
    });
    return false;*/
  }

  return (
    <main>
      <img src="/logo2.svg" alt="DFINITY logo" />
      <br />
      <br />
      <form action="#" onSubmit={handleSubmit}>
        <label htmlFor="name">Enter your name: &nbsp;</label>
        <input id="name" alt="Name" type="text" />
        <button type="submit">Click Me!</button>
      </form>
      <section id="greeting">{greeting}</section>
    </main>
  );
}

export default App;
