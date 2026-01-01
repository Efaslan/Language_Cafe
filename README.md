# Language Cafe Mobile

A mobile application designed for a cafe where customers socialize while practicing foreign languages.

## Features

- **Real-time Table Selection:** Users can create or join tables with specific language rules (e.g., English Only) by scanning QR codes unique to each table.
- **Live Occupancy:** Using WebSockets, users can see active tables, their current seat occupancy, and language rules in real-time to decide where to sit. This also allows users to remotely see whether the cafe is full or not.
- **In-App Ordering:** Allows customers to easily order products directly to their specific tables through the application after they scan the table's QR code.

## Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend & Database:** Supabase

---
*Note: This project relies on a Supabase backend and requires specific environment variables to run. I'd be happy to provide them if anyone's curious.*