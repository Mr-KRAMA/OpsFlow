# OpsFlow – IT Incident and Service Management Platform

**OpsFlow** is a complete, production-ready enterprise IT Service Management (ITSM) application designed to handle ticket lifecycle, SLA enforcement, user assignments, and IT assets.

---

## Resume Summary

**PROJECT NAME**: OpsFlow – Enterprise IT Service Management Platform

*A full-stack incident and service management system mimicking enterprise IT support workflows.*

* Designed and developed a modular monolith Spring Boot 3 backend using Java 17, Spring Data JPA, and PostgreSQL, ensuring scalable and maintainable enterprise architecture.
* Implemented secure, role-based access control (RBAC) utilizing Spring Security and stateless JWT authentication, enforcing strict permissions for Employees, Agents, and Admins.
* Engineered an automated SLA tracking engine with Spring `@Scheduled` tasks to monitor ticket response and resolution deadlines, improving simulated support efficiency by prioritizing critical incidents.
* Integrated Aspect-Oriented Programming (AOP) for immutable audit logging, capturing over 15 unique lifecycle state transitions to maintain compliance and traceability.
* Built a responsive Single Page Application (SPA) dashboard using React, TypeScript, and Tailwind CSS, featuring role-specific data aggregation, secure routing, and real-time form validation.

---

## 1. Project Overview & Problem Statement
Organizations need a structured way to report IT incidents and request services. Without a centralized tool, requests get lost, SLAs are breached, and support workload becomes unmanageable. OpsFlow solves this by providing a robust platform to categorize, assign, track, and resolve IT tickets with enforced SLAs and auditability.

## 2. Features
* **Role-Based Workflows**: Tailored experiences for Employees, Support Agents, Team Leads, and Admins.
* **Ticket Lifecycle Engine**: Strict state machine (New → Assigned → In Progress → Pending → Resolved).
* **SLA Management**: Automated monitoring of Response and Resolution deadlines based on priority.
* **Audit Logging**: Immutable tracking of all entity changes via Spring AOP.
* **Knowledge Base & Asset Management**: Integrated asset tagging and solution lookup.

## 3. Architecture & Tech Stack
* **Backend**: Java 17, Spring Boot 3, Spring Security, JWT, Spring Data JPA, Hibernate, Maven.
* **Frontend**: React 18, TypeScript, Vite, Tailwind CSS v4, React Router, Recharts, Axios.
* **Database**: PostgreSQL 15 (H2 used for local development testing).
* **Infrastructure**: Docker, Docker Compose, Nginx.

## 4. Database Schema (ER Diagram Description)
* **User (1)** to **Team (M)**: A user belongs to a specific team (e.g., IT Support).
* **User (1)** to **Ticket (M)**: A user can create many tickets, and an agent can be assigned many tickets.
* **Ticket (M)** to **TicketCategory (1)**: Each ticket falls under one category.
* **Ticket (1)** to **TicketComment (M)**: A ticket has multiple public or internal comments.
* **SLAPolicy (1)** to **Priority (1)**: Maps priorities (Low, Medium, High, Critical) to SLA hour thresholds.
* **AuditLog**: Standalone immutable table tracking `entityId`, `action`, and `userEmail`.

## 5. API Endpoint List

### Auth
* `POST /api/auth/register` - Register a new user
* `POST /api/auth/login` - Authenticate and get JWT

### Users & Teams
* `GET /api/users` - List users (Admin/Lead)
* `GET /api/teams` - List all teams

### Tickets
* `POST /api/tickets` - Create a ticket
* `GET /api/tickets` - Get all tickets (filtered by role)
* `GET /api/tickets/{id}` - Get ticket details
* `PATCH /api/tickets/{id}/status` - Update ticket status
* `PATCH /api/tickets/{id}/assign` - Assign agent/team
* `POST /api/tickets/{id}/comments` - Add a comment

### Other
* `GET /api/notifications` - Get user notifications
* `GET /api/assets` - List IT assets
* `GET /api/dashboard/admin` - Admin analytics metrics

---

## 6. Local Setup Instructions

### Prerequisites
* Java 17+
* Node.js 18+
* Maven

### Backend
1. Navigate to `/backend`.
2. Ensure you have Java 17.
3. Run `./mvnw spring-boot:run` (Runs with in-memory H2 database by default).

### Frontend
1. Navigate to `/frontend`.
2. Run `npm install`.
3. Run `npm run dev`.
4. Open `http://localhost:5173`.

---

## 7. Docker Setup Instructions
To run the full stack (PostgreSQL, Spring Boot Backend, Nginx React Frontend):
1. Navigate to the root directory.
2. Run `docker compose up -d --build`.
3. The frontend is accessible at `http://localhost:80` and the backend at `http://localhost:8080`.

---

## 8. Interview Preparation

### Interview Questions to Expect:
1. **Why did you choose a monolithic architecture instead of microservices?**
   *Answer*: For a platform of this scope, a modular monolith minimizes network latency, simplifies transaction management (e.g., updating a ticket and creating an audit log in one transaction), and speeds up deployment. Microservices would introduce unnecessary complexity here.
2. **How did you implement Role-Based Access Control?**
   *Answer*: I used Spring Security with a custom `JwtAuthenticationFilter`. The `SecurityContextHolder` is populated with a `UserDetails` object containing `GrantedAuthority` roles. I then used `@PreAuthorize` on controller methods to restrict access.
3. **How does the SLA engine work?**
   *Answer*: I used Spring's `@Scheduled` annotation to run a background job that polls active tickets and compares the current time against the `responseSlaDeadline` and `resolutionSlaDeadline`. 
4. **How did you handle the immutable audit logging?**
   *Answer*: I utilized Spring AOP (Aspect-Oriented Programming). I created a custom `@Auditable` annotation and an `AuditAspect` that intercepts method executions, extracts the entity state, and saves an `AuditLog` record transparently, keeping the business logic clean.

### 60-Second Elevator Pitch
"OpsFlow is a comprehensive IT Service Management platform I built using Spring Boot and React. It mirrors enterprise tools like ServiceNow by handling the full ticket lifecycle, from creation to resolution, while enforcing strict role-based access control. I implemented an automated SLA tracking engine to ensure critical incidents are flagged if response deadlines are breached, and I utilized Spring AOP to maintain an immutable audit trail of all ticket state transitions. It's fully containerized using Docker and uses PostgreSQL for data persistence, demonstrating my ability to build robust, scalable, and secure full-stack enterprise applications."

### 2-Minute Detailed Explanation
"For my recent project, I developed OpsFlow, an enterprise-grade IT Incident and Service Management Platform. My goal was to build something beyond a standard CRUD app, focusing on real-world business rules. 

On the backend, I used **Java 17 and Spring Boot 3**. I architected it as a clean modular monolith, separating controllers, services, repositories, and security layers. The core feature is the ticket lifecycle state machine—I wrote strict validation logic ensuring tickets only flow through authorized states, like 'New' to 'Assigned' to 'In Progress'. 

To handle security, I implemented **stateless JWT authentication** with Spring Security. A critical requirement was Role-Based Access Control (RBAC)—employees can only view their own tickets, while agents can view team queues and add internal notes invisible to the end-user. I secured this at the API level using `@PreAuthorize`.

Two advanced features I'm proud of are the **SLA Engine** and the **Audit Logger**. For SLAs, I configured a Spring `@Scheduled` background job that continuously evaluates ticket deadlines against dynamically calculated business rules based on Urgency and Impact. For the audit trail, instead of cluttering my service classes, I used **Spring AOP**. I created a custom `@Auditable` annotation that intercepts state changes and automatically logs the action, user, and timestamp to a separate audit table.

On the frontend, I built a responsive SPA using **React, TypeScript, and Tailwind CSS v4**, communicating with the backend via Axios. Finally, I containerized the entire stack—PostgreSQL, the Java backend, and an Nginx-served React frontend—using **Docker Compose**, making it instantly deployable. The result is a highly maintainable, secure, and performant enterprise application."
