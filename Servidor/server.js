const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// Configuración de la conexión MySQL
const db = mysql.createConnection({
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: '',
  database: 'rpgdatabase',
  connectTimeout: 10000
});

// Verifica la conexión
db.connect((err) => {
  if (err) {
    console.error('Error de conexión a la base de datos:', err.stack);
    return;
  }
  console.log('Conexión a la base de datos MySQL establecida con éxito');
});

// ✅ NUEVO ENDPOINT LIMPIO: solo proyectos// ✅ NUEVO ENDPOINT LIMPIO: solo proyectos
app.get('/proyectos', (req, res) => {
  const query = `
    SELECT 
      p.Id_Proyecto,
      p.Nombre_Proyecto,
      p.Ubicacion,
      p.Presupuesto,
      p.Adelantos,
      p.Fecha_Inicio,
      p.Fecha_Fin,
      p.Estado,
      c.Id_Usuario_Sistema AS Cliente_Id,
      c.Nombre_Usuario AS Cliente_Nombre
    FROM proyectos p
    JOIN usuarios_sistema c ON p.Id_Cliente = c.Id_Usuario_Sistema
    ORDER BY 
      CASE 
        WHEN p.Nombre_Proyecto = 'RPG' THEN 0 
        ELSE 1 
      END,
      p.Id_Proyecto;
  `;

  db.query(query, (err, rows) => {
    if (err) {
      console.error('Error al obtener proyectos:', err);
      return res.status(500).json({ error: 'Error en el servidor' });
    }

    res.json(rows);
  });
});


app.get('/proveedores', (req, res) => {
  const query = `
    SELECT * FROM usuarios_sistema WHERE Id_Tipo_Usuario IN (2, 3);
  `;

  db.query(query, (err, rows) => {
    if (err) {
      console.error('Error al obtener proveedores:', err);
      return res.status(500).json({ error: 'Error en el servidor' });
    }

    res.json(rows);
  });
});

app.get('/movimientosProyecto', (req, res) => {
  const idProyecto = req.query.idProyecto;

  const query = `
    SELECT * FROM movimientos_contables WHERE Id_Proyecto = ?;
  `;

  db.query(query, [idProyecto], (err, rows) => {
    if (err) {
      console.error('Error al obtener movimientos contables:', err);
      return res.status(500).json({ error: 'Error en el servidor' });
    }

    res.json(rows);
  });
});


//Personal
app.get('/usuarios', (req, res) => {
  const query = 'SELECT * FROM usuarios_sistema';

  db.query(query, (err, rows) => {
    if (err) {
      console.error('Error al obtener los usuarios:', err);
      return res.status(500).json({ error: 'Error al obtener los usuarios' });
    }

    res.status(200).json(rows);
  });
});


app.post('/crear_usuario', (req, res) => {
  const {
    Nombre_Usuario,
    Id_Tipo_Usuario,
    Telefono,
    Cedula,
    Licencia,
    Direccion
  } = req.body;

  const query = `
    INSERT INTO usuarios_sistema 
    (Nombre_Usuario, Id_Tipo_Usuario, Telefono, Cedula, Licencia, Direccion)
    VALUES (?, ?, ?, ?, ?, ?);
  `;

  db.query(
    query,
    [Nombre_Usuario, Id_Tipo_Usuario, Telefono, Cedula, Licencia, Direccion],
    (err, result) => {
      if (err) {
        console.error('Error al insertar usuario:', err);
        return res.status(500).json({ error: 'Error al insertar el usuario' });
      }

      res.status(200).json({ message: 'Usuario creado correctamente', id: result.insertId });
    }
  );
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
