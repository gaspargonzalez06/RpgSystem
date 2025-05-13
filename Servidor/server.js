const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
const PORT = 3002;

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

app.get('/movimientosUsuario', (req, res) => {
  const query = `
    SELECT 
      us.Id_Usuario_Sistema,
      us.Nombre_Usuario,
      us.Id_Tipo_Usuario,
      mc.*
    FROM movimientos_contables mc
    JOIN usuarios_sistema us 
      ON us.Id_Usuario_Sistema = COALESCE(mc.Id_Trabajador, mc.Id_Proveedor)
    ORDER BY us.Id_Usuario_Sistema;
  `;

  db.query(query, (err, rows) => {
    if (err) {
      console.error('Error al ejecutar la consulta:', err);
      return res.status(500).json({ error: 'Error en el servidor', details: err });
    }

    const agrupado = {};

    // Agrupar movimientos por Id_Usuario_Sistema
    rows.forEach((row) => {
      const userId = row.Id_Usuario_Sistema;

      if (!agrupado[userId]) {
        agrupado[userId] = {
          usuario: {
            Id_Usuario_Sistema: row.Id_Usuario_Sistema,
            Nombre_Usuario: row.Nombre_Usuario,
            Id_Tipo_Usuario : row.Id_Tipo_Usuario
          },
          movimientos: []
        };
      }

      // Excluir los campos de usuario duplicados en los movimientos
      const movimiento = { ...row };
      delete movimiento.Id_Usuario_Sistema;
      delete movimiento.Nombre_Usuario;

      agrupado[userId].movimientos.push(movimiento);
    });

    // Convertir el objeto agrupado en array
    const resultado = Object.values(agrupado);

    res.json(resultado);
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

//movimientos contables

app.post('/crear_movimiento', (req, res) => {
  const {
    Id_Ciente,
    Id_Servicio,
    Id_Tipo_Movimiento,
    Monto,
    Comentario,
    Id_Proyecto,
    Id_Admin,
    Id_Trabajador,
    Id_Proveedor
  } = req.body;

  const query = `
    INSERT INTO movimientos_contables 
    (Id_Ciente, Id_Servicio, Id_Tipo_Movimiento, Monto, Comentario, Fecha_Movimiento, Id_Proyecto, Id_Admin, Id_Trabajador, Id_Proveedor)
    VALUES (?, ?, ?, ?, ?, NOW(), ?, ?, ?, ?);
  `;

  db.query(
    query,
    [Id_Ciente, Id_Servicio, Id_Tipo_Movimiento, Monto, Comentario, Id_Proyecto, Id_Admin, Id_Trabajador, Id_Proveedor],
    (err, result) => {
      if (err) {
        console.error('Error al insertar movimiento:', err);
        return res.status(500).json({ error: 'Error al insertar el movimiento' });
      }

      res.status(200).json({ message: 'Movimiento creado correctamente', id: result.insertId });
    }
  );
});



// Iniciar servidor
app.listen(PORT,'0.0.0.0', () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
