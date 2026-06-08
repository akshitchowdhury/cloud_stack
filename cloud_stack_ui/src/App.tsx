import { useEffect, useState } from 'react'
import type { ChangeEvent, SubmitEvent } from 'react'

interface User {
  id: number
  name: string
  age: number | null
  email: string
}

function App() {
  const [data, setData] = useState<User[] | null>(null);

  const [name, setName] = useState('');
  const [age, setAge] = useState('');
  const [email, setEmail] = useState('');

  const handleFetchData = async () => {
    try {
      const response = await fetch('/api/users');
      const data = await response.json();
      console.log(data);
      setData(data);
    } catch (error) {
      console.error('Error fetching data:', error);
    }



  }

  const handleCreateUser = async (e: SubmitEvent<HTMLFormElement>) => {
    e.preventDefault();
    try {
      const response = await fetch('/api/users/createTest', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          name,
          age: age === '' ? null : Number(age),
          email,
        }),
      });
      const created = await response.json();
      console.log(created);
      setName('');
      setAge('');
      setEmail('');
      handleFetchData();
    } catch (error) {
      console.error('Error creating user:', error);
    }
  }


  useEffect(() => {
    handleFetchData();
  }, []);
  return (
    <div className="mx-auto flex min-h-svh max-w-3xl flex-col gap-8 px-4 py-10">
      <h1 className="text-center text-4xl font-semibold tracking-tight text-gray-900 dark:text-gray-100">
        Testing repo
      </h1>

      <section className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm dark:border-gray-700 dark:bg-gray-800">
        <h2 className="mb-4 text-xl font-medium text-gray-900 dark:text-gray-100">Add a user</h2>
        <form className="grid gap-4 sm:grid-cols-3" onSubmit={handleCreateUser}>
          <div className="flex flex-col gap-1">
            <label htmlFor="name" className="text-sm font-medium text-gray-700 dark:text-gray-300">Name</label>
            <input
              id="name"
              type="text"
              placeholder="Jane Doe"
              value={name}
              onChange={(e: ChangeEvent<HTMLInputElement>) => setName(e.target.value)}
              required
              className="rounded-md border border-gray-300 px-3 py-2 text-sm text-gray-900 outline-none focus:border-purple-500 focus:ring-1 focus:ring-purple-500 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100"
            />
          </div>
          <div className="flex flex-col gap-1">
            <label htmlFor="age" className="text-sm font-medium text-gray-700 dark:text-gray-300">Age</label>
            <input
              id="age"
              type="number"
              placeholder="30"
              value={age}
              onChange={(e: ChangeEvent<HTMLInputElement>) => setAge(e.target.value)}
              className="rounded-md border border-gray-300 px-3 py-2 text-sm text-gray-900 outline-none focus:border-purple-500 focus:ring-1 focus:ring-purple-500 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100"
            />
          </div>
          <div className="flex flex-col gap-1">
            <label htmlFor="email" className="text-sm font-medium text-gray-700 dark:text-gray-300">Email</label>
            <input
              id="email"
              type="email"
              placeholder="jane@example.com"
              value={email}
              onChange={(e: ChangeEvent<HTMLInputElement>) => setEmail(e.target.value)}
              required
              className="rounded-md border border-gray-300 px-3 py-2 text-sm text-gray-900 outline-none focus:border-purple-500 focus:ring-1 focus:ring-purple-500 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100"
            />
          </div>
          <button
            className="sm:col-span-3 rounded-md bg-purple-600 px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-purple-700"
            type="submit"
          >
            Add User
          </button>
        </form>
      </section>

      <section className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm dark:border-gray-700 dark:bg-gray-800">
        <h2 className="mb-4 text-xl font-medium text-gray-900 dark:text-gray-100">Users</h2>
        <div className="grid gap-4 sm:grid-cols-2">
          {
            data && data.map((user) => (
              <div key={user.id} className="flex items-center gap-3 rounded-lg border border-gray-200 p-4 dark:border-gray-700">
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-purple-100 text-sm font-semibold text-purple-700 dark:bg-purple-900 dark:text-purple-200">
                  {user.name ? user.name.charAt(0).toUpperCase() : '?'}
                </div>
                <div className="min-w-0">
                  <p className="truncate font-medium text-gray-900 dark:text-gray-100">{user.name}</p>
                  <p className="truncate text-sm text-gray-500 dark:text-gray-400">{user.email}</p>
                </div>
              </div>
            ))
          }
        </div>
      </section>
    </div>
  )
}

export default App
