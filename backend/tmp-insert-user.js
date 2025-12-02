const { Client } = require('pg');
(async ()=>{
  const client = new Client({
    connectionString: 'postgresql://immobilier_db_6phq_user:e21R1u9tThN2vUhSO8UB2F3ElNQU9Nc6@dpg-d4mv081r0fns73ahe9p0-a.frankfurt-postgres.render.com/immobilier_db_6phq',
    ssl: { rejectUnauthorized: false }
  });
  await client.connect();
  try {
    const res = await client.query(`INSERT INTO users (email,password,name,phone,role) VALUES ($1,$2,$3,$4,$5) RETURNING id`,['tmpuser@example.com','hashedpw','Tmp User','+216','visitor']);
    console.log('Inserted id', res.rows[0].id);
  } catch (e) {
    console.error('DB error:', e);
  } finally { await client.end(); }
})();
