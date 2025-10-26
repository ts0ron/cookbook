import { useState } from 'react'
import './App.css'

function App() {
  const [name, setName] = useState('')
  const [result, setResult] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')
    setResult('')

    try {
      const url = name ? `/hello/world?name=${encodeURIComponent(name)}` : '/hello/world'
      const response = await fetch(url)
      
      if (!response.ok) {
        throw new Error('Failed to fetch')
      }
      
      const data = await response.text()
      setResult(data)
    } catch (err) {
      setError('Failed to connect to the server. Make sure the backend is running on port 3000.')
      console.error('Error:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="app">
      <div className="container">
        <h1>Hello World App</h1>
        
        <form onSubmit={handleSubmit} className="form">
          <div className="form-group">
            <label htmlFor="name">Enter your name:</label>
            <input
              id="name"
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="John"
              disabled={loading}
            />
          </div>
          
          <button type="submit" disabled={loading || !name.trim()}>
            {loading ? 'Submitting...' : 'Submit'}
          </button>
        </form>

        {error && (
          <div className="error">
            {error}
          </div>
        )}

        {result && (
          <div className="result">
            <h2>Response:</h2>
            <p>{result}</p>
          </div>
        )}
      </div>
    </div>
  )
}

export default App
