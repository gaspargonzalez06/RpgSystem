const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
const PORT = 3002;

app.use(cors());
app.use(express.json());

// Configuración de la conexión MySQL
// const db = mysql.createConnection({
//   host: 'localhost',
//   port: 3306,
//   user: 'root',
//   password: '',
//   database: 'rpgdatabase',
//   connectTimeout: 10000
// });
// const db = mysql.createConnection({
//   host: 'localhost',
//   port: 3306,
//   user: 'rpguser',
//   password: 'gG_06221911',
//   database: 'rpgdatabase',
//   connectTimeout: 10000
// });


// const db = mysql.createPool({
//   host: 'localhost',
//   port: 3306,
//   user: 'rpguser',
//   password: 'gG_06221911',
//   database: 'rpgdatabase',
//   waitForConnections: true,
//   connectionLimit: 10,
//   queueLimit: 0
// });


const db = mysql.createPool({
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: '',
  database: 'rpgdatabase',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Verifica la conexión
db.query('SELECT 1', (err, results) => {
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
  c.Cedula,
  p.Comentario,
  c.Licencia,
  p.dinero_banco,
  c.Id_Usuario_Sistema AS Cliente_Id,
  c.Nombre_Usuario AS Cliente_Nombre,
  c.telefono,
  -- Diferencia en días desde la última fecha de adelanto hasta hoy
  DATEDIFF(CURDATE(), ultimos_adelantos.Ultima_Fecha_Adelanto) AS Dias_Desde_Ultimo_Adelanto,
 
   SUM(CASE WHEN mc.Id_Tipo_Movimiento = 2 THEN mc.Monto ELSE 0 END) AS Gastos
FROM proyectos p
JOIN usuarios_sistema c ON p.Id_Cliente = c.Id_Usuario_Sistema
LEFT JOIN (
  SELECT 
    Id_Proyecto,
    MAX(Fecha_Movimiento) AS Ultima_Fecha_Adelanto
  FROM movimientos_contables
  WHERE Id_Tipo_Movimiento = 3
  GROUP BY Id_Proyecto
) ultimos_adelantos ON p.Id_Proyecto = ultimos_adelantos.Id_Proyecto
LEFT JOIN movimientos_contables mc ON mc.Id_Proyecto = p.Id_Proyecto
GROUP BY 
  p.Id_Proyecto,
  p.Nombre_Proyecto,
  p.Ubicacion,
  p.Presupuesto,
  p.Adelantos,
  p.Fecha_Inicio,
  p.Fecha_Fin,
  p.Estado,
  p.dinero_banco,
  c.Id_Usuario_Sistema,
  c.Nombre_Usuario,
  c.telefono,
  ultimos_adelantos.Ultima_Fecha_Adelanto
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

// ✅ ENDPOINT PARA REPORTERÍA DE PROYECTOS
app.get('/proyectos/reporteria', (req, res) => {
  const query = `
    SELECT 
      p.Id_Proyecto as id,
      p.Nombre_Proyecto as nombre,
      p.Presupuesto as presupuesto,
      p.Adelantos as adelantos,
      p.Fecha_Inicio as fechaInicio,
      SUM(CASE WHEN mc.Id_Tipo_Movimiento = 2 THEN mc.Monto ELSE 0 END) AS gastos
    FROM proyectos p
    LEFT JOIN movimientos_contables mc ON mc.Id_Proyecto = p.Id_Proyecto
    GROUP BY 
      p.Id_Proyecto,
      p.Nombre_Proyecto,
      p.Presupuesto,
      p.Adelantos,
      p.Fecha_Inicio
    ORDER BY p.Nombre_Proyecto;
  `;

  db.query(query, (err, rows) => {
    if (err) {
      console.error('Error al obtener proyectos para reportería:', err);
      return res.status(500).json({ 
        error: 'Error en el servidor',
        detalles: err.message 
      });
    }

    // Formatear los datos para la vista
    const proyectosFormateados = rows.map(proyecto => ({
      id: proyecto.id,
      nombre: proyecto.nombre,
      presupuesto: parseFloat(proyecto.presupuesto) || 0,
      adelantos: parseFloat(proyecto.adelantos) || 0,
      gastos: parseFloat(proyecto.gastos) || 0,
      fechaInicio: proyecto.fechaInicio
    }));

    res.json(proyectosFormateados);
  });
});

// ✅ ENDPOINT POST PARA REPORTERÍA DE PROYECTOS CON FILTRO POR FECHA_MOVIMIENTO
app.post('/proyectos/reporteria-filtrada', (req, res) => {
  const { fechaInicio, fechaFin } = req.body;

  let query = `
    SELECT 
      p.Id_Proyecto as id,
      p.Nombre_Proyecto as nombre,
      p.Presupuesto as presupuesto,
      p.Adelantos as adelantos,
      p.Fecha_Inicio as fechaInicio,
      SUM(CASE WHEN mc.Id_Tipo_Movimiento = 2 THEN mc.Monto ELSE 0 END) AS gastos
    FROM proyectos p
    LEFT JOIN movimientos_contables mc ON mc.Id_Proyecto = p.Id_Proyecto
  `;

  // Agregar filtro por Fecha_Movimiento si se proporcionan fechas
  const whereConditions = [];
  const queryParams = [];

  if (fechaInicio && fechaFin) {
    whereConditions.push('mc.Fecha_Movimiento BETWEEN ? AND ?');
    queryParams.push(fechaInicio, fechaFin);
  }

  if (whereConditions.length > 0) {
    query += ' WHERE ' + whereConditions.join(' AND ');
  }

  query += `
    GROUP BY 
      p.Id_Proyecto,
      p.Nombre_Proyecto,
      p.Presupuesto,
      p.Adelantos,
      p.Fecha_Inicio
    ORDER BY p.Nombre_Proyecto;
  `;

  db.query(query, queryParams, (err, rows) => {
    if (err) {
      console.error('Error al obtener proyectos para reportería filtrada:', err);
      return res.status(500).json({ 
        error: 'Error en el servidor',
        detalles: err.message 
      });
    }

    // Formatear los datos para la vista
    const proyectosFormateados = rows.map(proyecto => ({
      id: proyecto.id,
      nombre: proyecto.nombre,
      presupuesto: parseFloat(proyecto.presupuesto) || 0,
      adelantos: parseFloat(proyecto.adelantos) || 0,
      gastos: parseFloat(proyecto.gastos) || 0,
      fechaInicio: proyecto.fechaInicio,
      // Campos calculados
      rentabilidad: (parseFloat(proyecto.presupuesto) || 0) - (parseFloat(proyecto.gastos) || 0),
      ganancias: (parseFloat(proyecto.adelantos) || 0) - (parseFloat(proyecto.gastos) || 0),
      porCobrar: (parseFloat(proyecto.presupuesto) || 0) - (parseFloat(proyecto.adelantos) || 0)
    }));

    res.json(proyectosFormateados);
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

app.get('/usuarios_sistema/clientes', (req, res) => {
  const query = `SELECT * FROM usuarios_sistema WHERE Id_Tipo_Usuario = 4`;

  db.query(query, (err, rows) => {
    if (err) {
      console.error('Error al obtener clientes:', err);
      return res.status(500).json({ error: 'Error en el servidor' });
    }
    res.json(rows);
  });
});

app.post('/ModificarSaldoBanco', (req, res) => {
  const nuevoSaldo = req.body.nuevoSaldo;

  // Validación básica del valor recibido
  if (typeof nuevoSaldo !== 'number' || nuevoSaldo < 0) {
    return res.status(400).json({ error: 'Saldo inválido' });
  }

  const query = `
    UPDATE proyectos
    SET dinero_banco = ?
    WHERE Id_Proyecto = 2
  `;

  db.query(query, [nuevoSaldo], (err, result) => {
    if (err) {
      console.error('Error al actualizar el saldo:', err);
      return res.status(500).json({ error: 'Error en el servidor' });
    }

    res.json({ message: 'Saldo actualizado correctamente' });
  });
});

app.post('/ModificarProyecto', (req, res) => {
  const { id_proyecto, nombre_proyecto, comentario, ubicacion, fecha_inicio, fecha_fin } = req.body;

  // Validaciones básicas
  if (!id_proyecto || !nombre_proyecto || !ubicacion) {
    return res.status(400).json({ error: 'Datos incompletos' });
  }

  const query = `
    UPDATE proyectos 
    SET Nombre_Proyecto = ?, Comentario = ?, Ubicacion = ?, Fecha_Inicio = ?, Fecha_Fin = ?
    WHERE Id_Proyecto = ?
  `;

  db.query(query, [nombre_proyecto, comentario, ubicacion, fecha_inicio, fecha_fin, id_proyecto], (err, result) => {
    if (err) {
      console.error('Error al actualizar el proyecto:', err);
      return res.status(500).json({ error: 'Error en el servidor' });
    }

    res.json({ message: 'Proyecto actualizado correctamente' });
  });
});

app.post('/actualizarComentarioProyecto', (req, res) => {
  const { idProyecto, comentario } = req.body;

  // Validación básica
  if (!idProyecto || typeof comentario !== 'string') {
    return res.status(400).json({ error: 'Datos inválidos' });
  }

  const query = `
    UPDATE proyectos
    SET Comentario = ?
    WHERE Id_Proyecto = ?
  `;

  db.query(
    query,
    [comentario, idProyecto],
    (err, result) => {
      if (err) {
        console.error('Error al actualizar comentario:', err);
        return res.status(500).json({ error: 'Error en el servidor' });
      }

      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'Proyecto no encontrado' });
      }

      res.json({ message: 'Comentario actualizado correctamente' });
    }
  );
});


app.post('/ModificarEstadoProyecto', (req, res) => {
  const { nuevoEstado, idProyecto } = req.body;

  // Validación básica
  if (!nuevoEstado || typeof nuevoEstado !== 'string' || !idProyecto || typeof idProyecto !== 'number') {
    return res.status(400).json({ error: 'Datos inválidos' });
  }

  const query = `
    UPDATE proyectos
    SET Estado = ?
    WHERE Id_Proyecto = ?
  `;

  db.query(query, [nuevoEstado, idProyecto], (err, result) => {
    if (err) {
      console.error('Error al actualizar el estado:', err);
      return res.status(500).json({ error: 'Error en el servidor' });
    }

    res.json({ message: 'Estado del proyecto actualizado correctamente' });
  });
});


// app.get('/resumen-mensual', (req, res) => {
//   const query = `
//     SELECT 
//       DATE_FORMAT(Fecha_Movimiento, '%Y-%m') AS mes,
//       SUM(CASE WHEN Id_Tipo_Movimiento = 3 THEN Monto ELSE 0 END) AS totalIngresos,
//       SUM(CASE WHEN Id_Tipo_Movimiento = 1 THEN Monto ELSE 0 END) AS totalCostos,
//       SUM(CASE WHEN Id_Tipo_Movimiento = 2 THEN Monto ELSE 0 END) -
//       SUM(CASE WHEN Id_Tipo_Movimiento = 1 THEN Monto ELSE 0 END) AS ganancia
//     FROM movimientos_contables
//     GROUP BY DATE_FORMAT(Fecha_Movimiento, '%Y-%m')
//     ORDER BY mes;
//   `;

//   db.query(query, (err, rows) => {
//     if (err) {
//       console.error('Error al obtener resumen mensual:', err);
//       return res.status(500).json({ error: 'Error en el servidor' });
//     }

//     res.json(rows);
//   });
// });

app.get('/resumen-mensual', (req, res) => {
  const query = `
    SELECT 
      DATE_FORMAT(Fecha_Movimiento, '%Y-%m') AS mes,
      
      -- Adelantos como ingresos
      SUM(CASE WHEN Id_Tipo_Movimiento = 3 THEN Monto ELSE 0 END) AS totalIngresos,

      -- Costos netos: egresos (1) - devoluciones (2)
      SUM(CASE WHEN Id_Tipo_Movimiento = 1 THEN Monto ELSE 0 END) - 
      SUM(CASE WHEN Id_Tipo_Movimiento = 2 THEN Monto ELSE 0 END) AS totalCostos,

      -- Ganancia = ingresos - costos
      SUM(CASE WHEN Id_Tipo_Movimiento = 3 THEN Monto ELSE 0 END) -
      (SUM(CASE WHEN Id_Tipo_Movimiento = 1 THEN Monto ELSE 0 END) - 
       SUM(CASE WHEN Id_Tipo_Movimiento = 2 THEN Monto ELSE 0 END)) AS ganancia

    FROM movimientos_contables
    GROUP BY DATE_FORMAT(Fecha_Movimiento, '%Y-%m')
    ORDER BY mes;
  `;

  db.query(query, (err, rows) => {
    if (err) {
      console.error('❌ Error al obtener resumen mensual:', err);
      return res.status(500).json({ error: 'Error en el servidor' });
    }

    res.json(rows);
  });
});


app.get('/resumen-proyectos', (req, res) => {
  const query = `
    SELECT
      COUNT(*) AS totalProyectos,
      SUM(CASE WHEN Estado = 'Activo' THEN 1 ELSE 0 END) AS totalActivos,
      SUM(CASE WHEN Estado = 'Suspendido' THEN 1 ELSE 0 END) AS totalSuspendidos,
      SUM(CASE WHEN Estado = 'Cancelado' THEN 1 ELSE 0 END) AS totalCancelados,
      SUM(CASE WHEN Estado = 'Terminado' THEN 1 ELSE 0 END) AS totalTerminados
    FROM proyectos;
  `;

  db.query(query, (err, rows) => {
    if (err) {
      console.error('❌ Error al obtener resumen de proyectos:', err);
      return res.status(500).json({ error: 'Error en el servidor' });
    }

    res.json(rows[0]); // Devuelve el primer (y único) resultado
  });
});


// app.get('/resumen-mensual-actual', (req, res) => {
//   const query = `
//  SELECT 
//   -- Total: suma de tipo 1 + 2 + 3
//   SUM(CASE WHEN Id_Tipo_Movimiento IN (1, 2, 3) THEN Monto ELSE 0 END) AS total,

//   -- Costo: tipo 1 - tipo 2
//   SUM(CASE WHEN Id_Tipo_Movimiento = 1 THEN Monto ELSE 0 END) -
//   SUM(CASE WHEN Id_Tipo_Movimiento = 2 THEN Monto ELSE 0 END) AS cost,

//   -- Ganancia: tipo 2 - tipo 3
//   SUM(CASE WHEN Id_Tipo_Movimiento = 2 THEN Monto ELSE 0 END) -
//   SUM(CASE WHEN Id_Tipo_Movimiento = 3 THEN Monto ELSE 0 END) AS profit

// FROM movimientos_contables
// WHERE YEAR(Fecha_Movimiento) = YEAR(CURDATE())
//   AND MONTH(Fecha_Movimiento) = MONTH(CURDATE());

//   `;

//   db.query(query, (err, rows) => {
//     if (err) {
//       console.error('Error al obtener resumen mensual actual:', err);
//       return res.status(500).json({ error: 'Error en el servidor' });
//     }

//     if (rows.length > 0) {
//       const row = rows[0];
//       res.json({
//         total: row.total || 0,
//         cost: row.cost || 0,
//         profit: row.profit || 0
//       });
//     } else {
//       res.json({ total: 0, cost: 0, profit: 0 });
//     }
//   });
// });


app.get('/resumen-mensual-actual', (req, res) => {
  const query = `
    SELECT 
      -- Total: solo movimientos tipo 3 (ingresos reales / adelantos)
      SUM(CASE WHEN Id_Tipo_Movimiento = 3 THEN Monto ELSE 0 END) AS total,

      -- Costo: tipo 1 (gastos) - tipo 2 (descuentos)
     
      SUM(CASE WHEN Id_Tipo_Movimiento = 2 THEN Monto ELSE 0 END) AS cost,

      -- Ganancia = total - cost
      SUM(CASE WHEN Id_Tipo_Movimiento = 3 THEN Monto ELSE 0 END) - 
 
       SUM(CASE WHEN Id_Tipo_Movimiento = 2 THEN Monto ELSE 0 END) AS profit

    FROM movimientos_contables
    WHERE YEAR(Fecha_Movimiento) = YEAR(CURDATE())
      AND MONTH(Fecha_Movimiento) = MONTH(CURDATE());
  `;

  db.query(query, (err, rows) => {
    if (err) {
      console.error('❌ Error al obtener resumen mensual actual:', err);
      return res.status(500).json({ error: 'Error en el servidor' });
    }

    if (rows.length > 0) {
      const row = rows[0];
      res.json({
        total: row.total || 0,
        cost: row.cost || 0,
        profit: row.profit || 0
      });
    } else {
      res.json({ total: 0, cost: 0, profit: 0 });
    }
  });
});




// app.get('/resumen-general-proyectos', (req, res) => {
//   const query = `
//     SELECT 
//       -- Ingresos del proyecto 2
//       SUM(CASE WHEN Id_Tipo_Movimiento = 3 THEN Monto ELSE 0 END) AS total_ingresos,
      
//       -- Egresos del proyecto 2 (tipos 1 y 2)
//       SUM(CASE WHEN Id_Tipo_Movimiento IN (1, 2) THEN Monto ELSE 0 END) AS total_egresos
//     FROM movimientos_contables
 
//   `;

//   const bancoQuery = `SELECT Dinero_Banco FROM proyectos WHERE Id_Proyecto = 2;`;

//   db.query(query, (err, rows) => {
//     if (err) {
//       console.error('Error al obtener resumen de movimientos:', err);
//       return res.status(500).json({ error: 'Error en movimientos' });
//     }

//     const row = rows[0] || {};
//     const ingresos = row.total_ingresos || 0;
//     const egresos = row.total_egresos || 0;

//     db.query(bancoQuery, (err, bancoRows) => {
//       if (err) {
//         console.error('Error al obtener Dinero_Banco:', err);
//         return res.status(500).json({ error: 'Error en banco' });
//       }

//       const banco = bancoRows[0]?.Dinero_Banco || 0;

//       res.json({
//         ingresos,
//         egresos,
//         totalBanco: banco,
//         saldo: banco // el banco ya refleja el impacto real
//       });
//     });
//   });
// });
app.get('/resumen-general-proyectos', (req, res) => {
  // Obtener el mes y año actual para el filtro mensual
  const currentDate = new Date();
  const currentMonth = currentDate.getMonth() + 1;
  const currentYear = currentDate.getFullYear();

  // Consulta con parámetros interpolados (seguro si usas una librería que lo protege)
  const query = `
    SELECT 
      -- Totales generales
      SUM(CASE WHEN Id_Tipo_Movimiento = 3 THEN Monto ELSE 0 END) AS total_ingresos_general,
      SUM(CASE WHEN Id_Tipo_Movimiento IN ( 2) THEN Monto ELSE 0 END) AS total_egresos_general,
      
      -- Totales mensuales
      SUM(CASE WHEN Id_Tipo_Movimiento = 3 AND MONTH(Fecha_Movimiento) = ${currentMonth} AND YEAR(Fecha_Movimiento) = ${currentYear} THEN Monto ELSE 0 END) AS total_ingresos_mensual,
      SUM(CASE WHEN Id_Tipo_Movimiento IN ( 2) AND MONTH(Fecha_Movimiento) = ${currentMonth} AND YEAR(Fecha_Movimiento) = ${currentYear} THEN Monto ELSE 0 END) AS total_egresos_mensual
    FROM movimientos_contables
  `;

  const bancoQuery = `SELECT Dinero_Banco FROM proyectos WHERE Id_Proyecto = 2;`;

  db.query(query, (err, rows) => {
    if (err) {
      console.error('Error al obtener resumen de movimientos:', err);
      return res.status(500).json({ error: 'Error en movimientos' });
    }

    const row = rows[0] || {};
    
    // Datos generales
    const ingresosGeneral = row.total_ingresos_general || 0;
    const egresosGeneral = row.total_egresos_general || 0;
    
    // Datos mensuales
    const ingresosMensual = row.total_ingresos_mensual || 0;
    const egresosMensual = row.total_egresos_mensual || 0;

    db.query(bancoQuery, (err, bancoRows) => {
      if (err) {
        console.error('Error al obtener Dinero_Banco:', err);
        return res.status(500).json({ error: 'Error en banco' });
      }

      const banco = bancoRows[0]?.Dinero_Banco || 0;

      res.json({
        general: {
          ingresos: ingresosGeneral,
          egresos: egresosGeneral,
          saldo: ingresosGeneral - egresosGeneral
        },
        mensual: {
          ingresos: ingresosMensual,
          egresos: egresosMensual,
          saldo: ingresosMensual - egresosMensual
        },
        totalBanco: banco,
        saldo: banco
      });
    });
  });
});
app.post('/movimientosUsuario', (req, res) => {
  const { idProyecto } = req.body;

  if (!idProyecto) {
    return res.status(400).json({ error: 'Falta el parámetro idProyecto' });
  }

  const query = `
SELECT 
  us.Id_Usuario_Sistema,
  us.Nombre_Usuario,
  us.Id_Tipo_Usuario,
  mc.*,p.Crea_Proyecto
FROM movimientos_contables mc
LEFT JOIN usuarios_sistema us 
  ON us.Id_Usuario_Sistema = COALESCE(mc.Id_Trabajador, mc.Id_Proveedor)
  JOIN proyectos p on p.Id_Proyecto = mc.Id_Proyecto
WHERE mc.Id_Proyecto =  ?
ORDER BY us.Id_Usuario_Sistema;
  `;

  db.query(query, [idProyecto], (err, rows) => {
    if (err) {
      console.error('Error al ejecutar la consulta:', err);
      return res.status(500).json({ error: 'Error en el servidor', details: err });
    }

    const agrupado = {};

    rows.forEach((row) => {
      const userId = row.Id_Usuario_Sistema;

      if (!agrupado[userId]) {
        agrupado[userId] = {
          usuario: {
            Id_Usuario_Sistema: row.Id_Usuario_Sistema,
            Nombre_Usuario: row.Nombre_Usuario,
            Id_Tipo_Usuario: row.Id_Tipo_Usuario
          },
          movimientos: []
        };
      }

      const movimiento = { ...row };
      delete movimiento.Id_Usuario_Sistema;
      delete movimiento.Nombre_Usuario;

      agrupado[userId].movimientos.push(movimiento);
    });

    const resultado = Object.values(agrupado);

    res.json(resultado);
  });
});

// app.post('/movimientosProyecto', (req, res) => {
//   const { idProyecto } = req.body;

//   if (!idProyecto) {
//     return res.status(400).json({ error: 'Falta el parámetro idProyecto' });
//   }

//   const query = `
//     SELECT * FROM movimientos_contables WHERE Id_Proyecto = ?
//   `;

//   db.query(query, [idProyecto], (err, rows) => {
//     if (err) {
//       console.error('Error al obtener movimientos contables:', err);
//       return res.status(500).json({ error: 'Error en el servidor' });
//     }

//     res.json(rows);
//   });
// });


// Antes:
// app.get('/movimientosProyecto', (req, res) => {

// // Después:
// app.post('/movimientosProyecto', (req, res) => {
//   console.log("🔹 Body recibido:", req.body);
//   const idProyecto = req.body.idProyecto;
//   const query = `
//     SELECT * FROM movimientos_contables WHERE Id_Proyecto = ?;
//   `;

//   db.query(query, [idProyecto], (err, rows) => {
//     if (err) {
//       console.error('Error al obtener movimientos contables:', err);
//       return res.status(500).json({ error: 'Error en el servidor' });
//     }

//     res.json(rows);
//   });
// });


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

app.post('/crear_proyecto', (req, res) => {
  const {
    Nombre_Proyecto,
    Ubicacion,
    Id_Cliente,
    Presupuesto,
    Adelantos,
    Fecha_Inicio,
    Fecha_Fin,
    Estado,
    Comentario,
    Id_Admin
  } = req.body;

  const query = `
    INSERT INTO proyectos 
    (Nombre_Proyecto, Ubicacion, Id_Cliente, Presupuesto, Adelantos, Fecha_Inicio, Fecha_Fin, Estado,Comentario, Id_Admin)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?,?, ?);
  `;

  db.query(
    query,
    [
      Nombre_Proyecto,
      Ubicacion,
      Id_Cliente,
      Presupuesto,
      Adelantos,
      Fecha_Inicio,
      Fecha_Fin,
      Estado,
      Comentario,
      Id_Admin
    ],
    (err, result) => {
      if (err) {
        console.error('Error al insertar proyecto:', err);
        return res.status(500).json({ error: 'Error al insertar el proyecto' });
      }

      res.status(200).json({ message: 'Proyecto creado correctamente', id: result.insertId });
    }
  );
});



app.post('/crear_usuario', (req, res) => {
  const {
    Nombre_Usuario,
    Id_Tipo_Usuario,
    Telefono,
    Cedula,
    Licencia,
    Direccion,
    Placa_Auto,
    Cuenta_Banco,
    Comentario
  } = req.body;

  const query = `
    INSERT INTO usuarios_sistema 
    (Nombre_Usuario, Id_Tipo_Usuario, Telefono, Cedula, Licencia, Direccion, placa_auto, cuenta_banco, comentario)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
  `;

  db.query(
    query,
    [
      Nombre_Usuario, 
      Id_Tipo_Usuario, 
      Telefono, 
      Cedula, 
      Licencia, 
      Direccion,
      Placa_Auto,
      Cuenta_Banco,
      Comentario
    ],
    (err, result) => {
      if (err) {
        console.error('Error al insertar usuario:', err);
        return res.status(500).json({ error: 'Error al insertar el usuario' });
      }

      res.status(200).json({ message: 'Usuario creado correctamente', id: result.insertId });
    }
  );
});
// app.post('/crear_usuario', (req, res) => {
//   const {
//     Nombre_Usuario,
//     Id_Tipo_Usuario,
//     Telefono,
//     Cedula,
//     Licencia,
//     Direccion
//   } = req.body;

//   const query = `
//     INSERT INTO usuarios_sistema 
//     (Nombre_Usuario, Id_Tipo_Usuario, Telefono, Cedula, Licencia, Direccion)
//     VALUES (?, ?, ?, ?, ?, ?);
//   `;

//   db.query(
//     query,
//     [Nombre_Usuario, Id_Tipo_Usuario, Telefono, Cedula, Licencia, Direccion],
//     (err, result) => {
//       if (err) {
//         console.error('Error al insertar usuario:', err);
//         return res.status(500).json({ error: 'Error al insertar el usuario' });
//       }

//       res.status(200).json({ message: 'Usuario creado correctamente', id: result.insertId });
//     }
//   );
// });

// Node.js - Endpoint actualizado
app.put('/actualizar_usuario/:id', (req, res) => {
  const { id } = req.params;
  const {
    Nombre_Usuario,
    Telefono,
    Cedula,
    Licencia,
    Direccion,
    Placa_Auto,
    Cuenta_Banco,
    Comentario,
    Id_Tipo_Usuario  // Cambiado a mayúscula para coincidir
  } = req.body;

  const query = `
    UPDATE usuarios_sistema SET
      Nombre_Usuario = ?,
      Telefono = ?,
      Cedula = ?,
      Licencia = ?,
      Direccion = ?,
      placa_auto = ?,
      cuenta_banco = ?,
      comentario = ?,
      Id_Tipo_Usuario = ?
    WHERE Id_Usuario_Sistema = ?;
  `;

  db.query(
    query,
    [
      Nombre_Usuario,
      Telefono,
      Cedula,
      Licencia,
      Direccion,
      Placa_Auto,
      Cuenta_Banco,
      Comentario,
      Id_Tipo_Usuario,  // Usar el mismo nombre que en la destructuración
      id
    ],
    (err, result) => {
      if (err) {
        console.error('Error al actualizar usuario:', err);
        return res.status(500).json({ error: 'Error al actualizar el usuario' });
      }

      res.status(200).json({ message: 'Usuario actualizado correctamente' });
    }
  );
});
app.delete('/eliminar_usuario/:id', (req, res) => {
  const { id } = req.params;

  const query = 'DELETE FROM usuarios_sistema WHERE Id_Usuario_Sistema = ?';

  db.query(query, [id], (err, result) => {
    if (err) {
      console.error('Error al eliminar usuario:', err);
      return res.status(500).json({ error: 'Error al eliminar el usuario' });
    }

    res.status(200).json({ message: 'Usuario eliminado correctamente' });
  });
});

// app.put('/actualizar_usuario/:id', (req, res) => {
//   const { id } = req.params;
//   const {
//     Nombre_Usuario,
//     Telefono,
//     Cedula,
//     Licencia,
//     Direccion,
//     Placa_Auto,
//     Cuenta_Banco,
//     Comentario
//   } = req.body;

//   const query = `
//     UPDATE usuarios_sistema SET
//       Nombre_Usuario = ?,
//       Telefono = ?,
//       Cedula = ?,
//       Licencia = ?,
//       Direccion = ?,
//       placa_auto = ?,
//       cuenta_banco = ?,
//       comentario = ?
//     WHERE Id_Usuario_Sistema = ?;
//   `;

//   db.query(
//     query,
//     [
//       Nombre_Usuario,
//       Telefono,
//       Cedula,
//       Licencia,
//       Direccion,
//       Placa_Auto,
//       Cuenta_Banco,
//       Comentario,
//       id
//     ],
//     (err, result) => {
//       if (err) {
//         console.error('Error al actualizar usuario:', err);
//         return res.status(500).json({ error: 'Error al actualizar el usuario' });
//       }

//       res.status(200).json({ message: 'Usuario actualizado correctamente' });
//     }
//   );
// });

// app.put('/actualizar_usuario/:id', (req, res) => {
//   const { id } = req.params;
//   const {
//     Nombre_Usuario,
//     Telefono,
//     Cedula,
//     Licencia,
//     Direccion
//   } = req.body;

//   const query = `
//     UPDATE usuarios_sistema SET
//       Nombre_Usuario = ?,
//       Telefono = ?,
//       Cedula = ?,
//       Licencia = ?,
//       Direccion = ?
//     WHERE Id_Usuario_Sistema = ?;
//   `;

//   db.query(
//     query,
//     [Nombre_Usuario, Telefono, Cedula, Licencia, Direccion, id],
//     (err, result) => {
//       if (err) {
//         console.error('Error al actualizar usuario:', err);
//         return res.status(500).json({ error: 'Error al actualizar el usuario' });
//       }

//       res.status(200).json({ message: 'Usuario actualizado correctamente' });
//     }
//   );
// });

app.post('/usuarios_sistema/login', (req, res) => {
  const { Usuario, Contrasena } = req.body;

  const query = `
    SELECT Id_Usuario_Sistema, Nombre_Usuario, Id_Tipo_Usuario, Telefono, Cedula, Licencia, Direccion, Usuario
    FROM usuarios_sistema
    WHERE Usuario = ? AND Contraseña = ?
    LIMIT 1
  `;

  db.query(query, [Usuario, Contrasena], (err, results) => {
    if (err) {
      console.error('Error en login:', err);
      return res.status(500).json({ error: 'Error interno del servidor' });
    }

    if (results.length === 0) {
      return res.status(401).json({ error: 'Usuario o contraseña incorrectos' });
    }

    // Devolver solo la info del usuario (sin contraseña)
    const usuario = results[0];
    return res.status(200).json({ usuario });
  });
});



app.post('/editar_movimiento', (req, res) => {
  // 1. Extraer parámetros (nuevos campos son opcionales)
  const { Id_Movimiento, Monto, Comentario, Tipo_Movimiento, Pago_Directo } = req.body;

  // 2. Validaciones originales (sin cambios)
  if (!Id_Movimiento || isNaN(Id_Movimiento)) {
    return res.status(400).json({ success: false, error: 'ID inválido' });
  }

  if (!Monto || isNaN(Monto)) {
    return res.status(400).json({ success: false, error: 'Monto inválido' });
  }

  // 3. Validación opcional para Tipo_Movimiento si viene en el request
  if (Tipo_Movimiento !== undefined && ![1, 2].includes(parseInt(Tipo_Movimiento))) {
    return res.status(400).json({ success: false, error: 'Tipo de movimiento inválido. Debe ser 1 (Pendiente) o 2 (Pagado)' });
  }

  // 4. Obtener movimiento actual (original sin cambios)
  db.query(
    `SELECT Id_Proyecto, Monto AS MontoAnterior, Id_Tipo_Movimiento 
     FROM movimientos_contables WHERE Id_Movimiento = ?`,
    [Id_Movimiento],
    (err, results) => {
      if (err) {
        console.error('Error al obtener movimiento:', err);
        return res.status(500).json({ success: false, error: 'Error en base de datos' });
      }

      if (results.length === 0) {
        return res.status(404).json({ success: false, error: 'Movimiento no encontrado' });
      }

      const { Id_Proyecto, MontoAnterior, Id_Tipo_Movimiento } = results[0];
      const diferencia = parseFloat(Monto) - parseFloat(MontoAnterior);

      // 5. Construir consulta de actualización dinámica
      let updateQuery = `UPDATE movimientos_contables SET 
        Monto = ?, 
        Comentario = ?`;
      
      const updateParams = [Monto, Comentario || null];

      // Agregar nuevos campos solo si vienen en el request
      if (Tipo_Movimiento !== undefined) {
        updateQuery += `, Id_Tipo_Movimiento = ?`;
        updateParams.push(Tipo_Movimiento);
      }

      if (Pago_Directo !== undefined) {
        updateQuery += `, Pago_Directo = ?`;
        updateParams.push(Pago_Directo);
      }

      updateQuery += ` WHERE Id_Movimiento = ?`;
      updateParams.push(Id_Movimiento);

      // 6. Actualizar movimiento principal
      db.query(
        updateQuery,
        updateParams,
        (errUpdate) => {
          if (errUpdate) {
            console.error('Error al actualizar movimiento:', errUpdate);
            return res.status(500).json({ success: false, error: 'Error al actualizar movimiento' });
          }

          // 7. Lógica original de actualizaciones según tipo (sin cambios)
          if (Id_Tipo_Movimiento === 3) { // Adelanto
            db.query(
              `UPDATE proyectos SET Adelantos = Adelantos + ? WHERE Id_Proyecto = ?`,
              [diferencia, Id_Proyecto],
              (errAdelantos) => {
                if (errAdelantos) {
                  console.error('Error al actualizar adelantos:', errAdelantos);
                  return res.status(500).json({ 
                    success: false,
                    error: 'Movimiento actualizado pero error al ajustar adelantos' 
                  });
                }

                const operacionBanco = diferencia > 0 ? '-' : '+';
                const valorBanco = Math.abs(diferencia);
                
                db.query(
                  `UPDATE proyectos SET dinero_banco = dinero_banco ${operacionBanco} ? WHERE Id_Proyecto = 2`,
                  [valorBanco],
                  (errBanco) => {
                    if (errBanco) {
                      console.error('Error al actualizar banco:', errBanco);
                      return res.status(500).json({ 
                        success: false,
                        error: 'Movimiento actualizado pero error al ajustar banco' 
                      });
                    }

                    return res.status(200).json({ 
                      success: true,
                      message: 'Movimiento, adelantos y banco actualizados',
                      diferencia: diferencia,
                      operacion: `Banco ${operacionBanco} ${valorBanco}`
                    });
                  }
                );
              }
            );

          } else if (Id_Tipo_Movimiento === 2) { // Gasto (Deuda)
            const operacionBanco = diferencia > 0 ? '-' : '+';
            const valorBanco = Math.abs(diferencia);
            
            db.query(
              `UPDATE proyectos SET dinero_banco = dinero_banco ${operacionBanco} ? WHERE Id_Proyecto = 2`,
              [valorBanco],
              (errBanco) => {
                if (errBanco) {
                  console.error('Error al actualizar banco:', errBanco);
                  return res.status(500).json({ 
                    success: false,
                    error: 'Movimiento actualizado pero error al ajustar banco' 
                  });
                }

                return res.status(200).json({ 
                  success: true,
                  message: 'Movimiento y banco actualizados',
                  diferencia: diferencia,
                  operacion: `Banco ${operacionBanco} ${valorBanco}`
                });
              }
            );

          } else if (Id_Tipo_Movimiento === 4) { // Extra a presupuesto
            db.query(
              `UPDATE proyectos SET Presupuesto = Presupuesto + ? WHERE Id_Proyecto = ?`,
              [diferencia, Id_Proyecto],
              (errPresupuesto) => {
                if (errPresupuesto) {
                  console.error('Error al actualizar presupuesto:', errPresupuesto);
                  return res.status(500).json({ 
                    success: false,
                    error: 'Movimiento actualizado pero error al ajustar presupuesto' 
                  });
                }

                return res.status(200).json({ 
                  success: true,
                  message: 'Movimiento y presupuesto actualizados',
                  diferencia: diferencia
                });
              }
            );

          } else {
            return res.status(200).json({ 
              success: true,
              message: 'Movimiento actualizado correctamente',
              // Incluir los cambios aplicados en la respuesta
              cambios: {
                monto: Monto,
                comentario: Comentario,
                ...(Tipo_Movimiento !== undefined && { tipo_movimiento: Tipo_Movimiento }),
                ...(Pago_Directo !== undefined && { pago_directo: Pago_Directo })
              }
            });
          }
        }
      );
    }
  );
});
// app.post('/editar_movimiento', (req, res) => {
//   const { Id_Movimiento, Monto, Comentario } = req.body;

//   // Validaciones
//   if (!Id_Movimiento || isNaN(Id_Movimiento)) {
//     return res.status(400).json({ success: false, error: 'ID inválido' });
//   }

//   if (!Monto || isNaN(Monto)) {
//     return res.status(400).json({ success: false, error: 'Monto inválido' });
//   }

//   // 1. Obtener movimiento actual
//   db.query(
//     `SELECT Id_Proyecto, Monto AS MontoAnterior, Id_Tipo_Movimiento 
//      FROM movimientos_contables WHERE Id_Movimiento = ?`,
//     [Id_Movimiento],
//     (err, results) => {
//       if (err) {
//         console.error('Error al obtener movimiento:', err);
//         return res.status(500).json({ success: false, error: 'Error en base de datos' });
//       }

//       if (results.length === 0) {
//         return res.status(404).json({ success: false, error: 'Movimiento no encontrado' });
//       }

//       const { Id_Proyecto, MontoAnterior, Id_Tipo_Movimiento } = results[0];
//       const diferencia = parseFloat(Monto) - parseFloat(MontoAnterior);

//       // 2. Actualizar movimiento principal
//       db.query(
//         `UPDATE movimientos_contables 
//          SET Monto = ?, Comentario = ?
//          WHERE Id_Movimiento = ?`,
//         [Monto, Comentario || null, Id_Movimiento],
//         (errUpdate) => {
//           if (errUpdate) {
//             console.error('Error al actualizar movimiento:', errUpdate);
//             return res.status(500).json({ success: false, error: 'Error al actualizar movimiento' });
//           }

//           // 3. Manejar actualizaciones según tipo
//           if (Id_Tipo_Movimiento === 3) { // Adelanto
//             // Actualizar adelantos del proyecto (suma/resta según diferencia)
//             db.query(
//               `UPDATE proyectos SET Adelantos = Adelantos + ? WHERE Id_Proyecto = ?`,
//               [diferencia, Id_Proyecto],
//               (errAdelantos) => {
//                 if (errAdelantos) {
//                   console.error('Error al actualizar adelantos:', errAdelantos);
//                   return res.status(500).json({ 
//                     success: false,
//                     error: 'Movimiento actualizado pero error al ajustar adelantos' 
//                   });
//                 }

//                 // CORRECCIÓN: Para adelantos, si el monto aumenta (diferencia positiva)
//                 // debemos RESTAR del banco (porque sacamos más dinero)
//                 // Si el monto disminuye (diferencia negativa) SUMAMOS al banco (regresamos dinero)
//                 const operacionBanco = diferencia > 0 ? '+' : '-';
//                 const valorBanco = Math.abs(diferencia);
                
//                 db.query(
//                   `UPDATE proyectos SET dinero_banco = dinero_banco ${operacionBanco} ? WHERE Id_Proyecto = 2`,
//                   [valorBanco],
//                   (errBanco) => {
//                     if (errBanco) {
//                       console.error('Error al actualizar banco:', errBanco);
//                       return res.status(500).json({ 
//                         success: false,
//                         error: 'Movimiento actualizado pero error al ajustar banco' 
//                       });
//                     }

//                     return res.status(200).json({ 
//                       success: true,
//                       message: 'Movimiento, adelantos y banco actualizados',
//                       diferencia: diferencia,
//                       operacion: `Banco ${operacionBanco} ${valorBanco}`
//                     });
//                   }
//                 );
//               }
//             );

//           } else if (Id_Tipo_Movimiento === 2) { // Gasto (Deuda)
//             // Para gastos, si el monto aumenta (diferencia positiva)
//             // debemos RESTAR del banco (gastamos más)
//             // Si el monto disminuye (diferencia negativa) SUMAMOS al banco (recuperamos dinero)
//             const operacionBanco = diferencia > 0 ? '-' : '+';
//             const valorBanco = Math.abs(diferencia);
            
//             db.query(
//               `UPDATE proyectos SET dinero_banco = dinero_banco ${operacionBanco} ? WHERE Id_Proyecto = 2`,
//               [valorBanco],
//               (errBanco) => {
//                 if (errBanco) {
//                   console.error('Error al actualizar banco:', errBanco);
//                   return res.status(500).json({ 
//                     success: false,
//                     error: 'Movimiento actualizado pero error al ajustar banco' 
//                   });
//                 }

//                 return res.status(200).json({ 
//                   success: true,
//                   message: 'Movimiento y banco actualizados',
//                   diferencia: diferencia,
//                   operacion: `Banco ${operacionBanco} ${valorBanco}`
//                 });
//               }
//             );

//           } else if (Id_Tipo_Movimiento === 4) { // Extra a presupuesto
//             // Para extras, simplemente sumamos/restamos la diferencia al presupuesto
//             db.query(
//               `UPDATE proyectos SET Presupuesto = Presupuesto + ? WHERE Id_Proyecto = ?`,
//               [diferencia, Id_Proyecto],
//               (errPresupuesto) => {
//                 if (errPresupuesto) {
//                   console.error('Error al actualizar presupuesto:', errPresupuesto);
//                   return res.status(500).json({ 
//                     success: false,
//                     error: 'Movimiento actualizado pero error al ajustar presupuesto' 
//                   });
//                 }

//                 return res.status(200).json({ 
//                   success: true,
//                   message: 'Movimiento y presupuesto actualizados',
//                   diferencia: diferencia
//                 });
//               }
//             );

//           } else {
//             // Otros tipos de movimiento (solo actualización básica)
//             return res.status(200).json({ 
//               success: true,
//               message: 'Movimiento actualizado correctamente' 
//             });
//           }
//         }
//       );
//     }
//   );
// });
// app.post('/editar_movimiento', (req, res) => {
//   const { Id_Movimiento, Monto, Comentario } = req.body;

//   // Validaciones
//   if (!Id_Movimiento || isNaN(Id_Movimiento)) {
//     return res.status(400).json({ success: false, error: 'ID inválido' });
//   }

//   if (!Monto || isNaN(Monto)) {
//     return res.status(400).json({ success: false, error: 'Monto inválido' });
//   }

//   // 1. Obtener movimiento actual
//   db.query(
//     `SELECT Id_Proyecto, Monto AS MontoAnterior, Id_Tipo_Movimiento 
//      FROM movimientos_contables WHERE Id_Movimiento = ?`,
//     [Id_Movimiento],
//     (err, results) => {
//       if (err) {
//         console.error('Error al obtener movimiento:', err);
//         return res.status(500).json({ success: false, error: 'Error en base de datos' });
//       }

//       if (results.length === 0) {
//         return res.status(404).json({ success: false, error: 'Movimiento no encontrado' });
//       }

//       const { Id_Proyecto, MontoAnterior, Id_Tipo_Movimiento } = results[0];
//       const diferencia = parseFloat(Monto) - parseFloat(MontoAnterior);

//       // 2. Actualizar movimiento principal
//       db.query(
//         `UPDATE movimientos_contables 
//          SET Monto = ?, Comentario = ?
//          WHERE Id_Movimiento = ?`,
//         [Monto, Comentario || null, Id_Movimiento],
//         (errUpdate) => {
//           if (errUpdate) {
//             console.error('Error al actualizar movimiento:', errUpdate);
//             return res.status(500).json({ success: false, error: 'Error al actualizar movimiento' });
//           }

//           // 3. Manejar actualizaciones según tipo
//           if (Id_Tipo_Movimiento === 3) { // Adelanto
//             // Actualizar adelantos del proyecto (suma/resta según diferencia)
//             db.query(
//               `UPDATE proyectos SET Adelantos = Adelantos + ? WHERE Id_Proyecto = ?`,
//               [diferencia, Id_Proyecto],
//               (errAdelantos) => {
//                 if (errAdelantos) {
//                   console.error('Error al actualizar adelantos:', errAdelantos);
//                   return res.status(500).json({ 
//                     success: false,
//                     error: 'Movimiento actualizado pero error al ajustar adelantos' 
//                   });
//                 }

//                 // Actualizar banco (proyecto 2) - lógica inversa
//                 const operacionBanco = diferencia > 0 ? '-' : '+';
//                 const valorBanco = Math.abs(diferencia);
                
//                 db.query(
//                   `UPDATE proyectos SET dinero_banco = dinero_banco ${operacionBanco} ? WHERE Id_Proyecto = 2`,
//                   [valorBanco],
//                   (errBanco) => {
//                     if (errBanco) {
//                       console.error('Error al actualizar banco:', errBanco);
//                       return res.status(500).json({ 
//                         success: false,
//                         error: 'Movimiento actualizado pero error al ajustar banco' 
//                       });
//                     }

//                     return res.status(200).json({ 
//                       success: true,
//                       message: 'Movimiento, adelantos y banco actualizados',
//                       diferencia: diferencia
//                     });
//                   }
//                 );
//               }
//             );

//           } else if (Id_Tipo_Movimiento === 2) { // Gasto (Deuda)
//             // Actualizar banco (proyecto 2) - lógica inversa
//             const operacionBanco = diferencia > 0 ? '-' : '+';
//             const valorBanco = Math.abs(diferencia);
            
//             db.query(
//               `UPDATE proyectos SET dinero_banco = dinero_banco ${operacionBanco} ? WHERE Id_Proyecto = 2`,
//               [valorBanco],
//               (errBanco) => {
//                 if (errBanco) {
//                   console.error('Error al actualizar banco:', errBanco);
//                   return res.status(500).json({ 
//                     success: false,
//                     error: 'Movimiento actualizado pero error al ajustar banco' 
//                   });
//                 }

//                 return res.status(200).json({ 
//                   success: true,
//                   message: 'Movimiento y banco actualizados',
//                   diferencia: diferencia
//                 });
//               }
//             );

//           } else if (Id_Tipo_Movimiento === 4) { // Extra a presupuesto
//             // Actualizar presupuesto del proyecto (suma/resta según diferencia)
//             db.query(
//               `UPDATE proyectos SET Presupuesto = Presupuesto + ? WHERE Id_Proyecto = ?`,
//               [diferencia, Id_Proyecto],
//               (errPresupuesto) => {
//                 if (errPresupuesto) {
//                   console.error('Error al actualizar presupuesto:', errPresupuesto);
//                   return res.status(500).json({ 
//                     success: false,
//                     error: 'Movimiento actualizado pero error al ajustar presupuesto' 
//                   });
//                 }

//                 return res.status(200).json({ 
//                   success: true,
//                   message: 'Movimiento y presupuesto actualizados',
//                   diferencia: diferencia
//                 });
//               }
//             );

//           } else {
//             // Otros tipos de movimiento (solo actualización básica)
//             return res.status(200).json({ 
//               success: true,
//               message: 'Movimiento actualizado correctamente' 
//             });
//           }
//         }
//       );
//     }
//   );
// });
// app.post('/editar_movimiento', (req, res) => {
//   console.log('Recibida solicitud para editar movimiento:', req.body); // Log para depuración

//   const { 
//     Id_Movimiento,
//     Monto, 
//     Comentario
    
//   } = req.body;

//   // Validación mejorada
//   if (!Id_Movimiento || isNaN(parseInt(Id_Movimiento))) {
//     console.error('ID de movimiento inválido recibido:', Id_Movimiento);
//     return res.status(400).json({ 
//       success: false,
//       error: 'ID de movimiento inválido' 
//     });
//   }

//   if (!Monto || isNaN(parseFloat(Monto))) {
//     console.error('Monto inválido recibido:', Monto);
//     return res.status(400).json({ 
//       success: false,
//       error: 'Monto inválido' 
//     });
//   }



//   const query = `
//     UPDATE movimientos_contables 
//     SET 
//       Monto = ?,
//       Comentario = ?

//     WHERE Id_Movimiento = ?
//   `;

//   const params = [
//     parseFloat(Monto),
//     Comentario || null,
//     parseInt(Id_Movimiento)
//   ];

//   console.log('Ejecutando consulta SQL:', query, 'con parámetros:', params);

//   db.query(query, params, (err, results) => {
//     if (err) {
//       console.error('Error en la consulta SQL:', err);
//       return res.status(500).json({ 
//         success: false,
//         error: 'Error en la base de datos al actualizar el movimiento' 
//       });
//     }

//     console.log('Resultados de la consulta:', results);

//     if (results.affectedRows === 0) {
//       return res.status(404).json({ 
//         success: false,
//         error: 'Movimiento no encontrado o sin cambios' 
//       });
//     }

//     return res.status(200).json({ 
//       success: true,
//       message: 'Movimiento actualizado correctamente',
//       movimientoId: Id_Movimiento
//     });
//   });
// });


app.post('/eliminar_movimiento', (req, res) => {
  const { Id_Movimiento } = req.body;

  if (!Id_Movimiento || isNaN(Id_Movimiento)) {
    return res.status(400).json({ error: 'ID de movimiento inválido' });
  }

  // Primero obtener los datos del movimiento
  const queryGet = `
    SELECT Id_Proyecto, Monto, Id_Tipo_Movimiento 
    FROM movimientos_contables 
    WHERE Id_Movimiento = ?
  `;

  db.query(queryGet, [parseInt(Id_Movimiento)], (err, results) => {
    if (err) {
      console.error('Error al obtener movimiento:', err);
      return res.status(500).json({ error: 'Error al consultar movimiento' });
    }

    if (results.length === 0) {
      return res.status(404).json({ error: 'Movimiento no encontrado' });
    }

    const { Id_Proyecto, Monto, Id_Tipo_Movimiento } = results[0];

    // Eliminar el movimiento
    const queryDelete = `
      DELETE FROM movimientos_contables 
      WHERE Id_Movimiento = ?
    `;

    db.query(queryDelete, [parseInt(Id_Movimiento)], (errDelete, deleteResults) => {
      if (errDelete) {
        console.error('Error al eliminar movimiento:', errDelete);
        return res.status(500).json({ error: 'Error al eliminar movimiento' });
      }

      // Manejar actualizaciones según el tipo de movimiento
      if (Id_Tipo_Movimiento === 4) { // Extra a presupuesto
        const queryUpdatePresupuesto = `
          UPDATE proyectos
          SET Presupuesto = Presupuesto - ?
          WHERE Id_Proyecto = ?
        `;

        db.query(queryUpdatePresupuesto, [Monto, Id_Proyecto], (errUpdate) => {
          if (errUpdate) {
            console.error('Error al actualizar presupuesto:', errUpdate);
            return res.status(500).json({ 
              error: 'Movimiento eliminado pero error al actualizar presupuesto',
              success: true
            });
          }
          return res.status(200).json({ 
            success: true,
            message: 'Movimiento eliminado y presupuesto ajustado' 
          });
        });

      } else if (Id_Tipo_Movimiento === 3) { // Adelanto
        // Primero actualizar adelantos
        const queryUpdateAdelantos = `
          UPDATE proyectos
          SET Adelantos = Adelantos - ?
          WHERE Id_Proyecto = ?
        `;

        db.query(queryUpdateAdelantos, [Monto, Id_Proyecto], (errAdelantos) => {
          if (errAdelantos) {
            console.error('Error al actualizar adelantos:', errAdelantos);
            return res.status(500).json({ 
              error: 'Movimiento eliminado pero error al actualizar adelantos',
              success: true
            });
          }

          // Luego actualizar banco (proyecto 2)
          const queryUpdateBanco = `
            UPDATE proyectos
            SET dinero_banco = dinero_banco - ?
            WHERE Id_Proyecto = 2
          `;

          db.query(queryUpdateBanco, [Monto], (errBanco) => {
            if (errBanco) {
              console.error('Error al actualizar dinero_banco:', errBanco);
              return res.status(500).json({ 
                error: 'Movimiento eliminado pero error al actualizar banco',
                success: true
              });
            }

            return res.status(200).json({ 
              success: true,
              message: 'Movimiento eliminado y ambos campos ajustados' 
            });
          });
        });

      } else if (Id_Tipo_Movimiento === 2) { // Gasto
        const queryUpdateBanco = `
          UPDATE proyectos
          SET dinero_banco = dinero_banco + ?
          WHERE Id_Proyecto = 2
        `;

        db.query(queryUpdateBanco, [Monto], (errBanco) => {
          if (errBanco) {
            console.error('Error al actualizar dinero_banco:', errBanco);
            return res.status(500).json({ 
              error: 'Movimiento eliminado pero error al actualizar banco',
              success: true
            });
          }

          return res.status(200).json({ 
            success: true,
            message: 'Movimiento eliminado y banco ajustado' 
          });
        });

      } else {
        // Otros tipos de movimiento (solo eliminación)
        return res.status(200).json({ 
          success: true,
          message: 'Movimiento eliminado correctamente' 
        });
      }
    });
  });
});



app.post('/crear_movimiento', (req, res) => {
  // const {
  //   Id_Cliente,
  //   Id_Servicio,
  //   Id_Tipo_Movimiento,
  //   Monto,
  //   Comentario,
  //   Id_Proyecto,
  //   Id_Admin,
  //   Id_Trabajador,
  //   Id_Proveedor
  // } = req.body;

  // const queryInsert = `
  //   INSERT INTO movimientos_contables 
  //   (Id_Cliente, Id_Servicio, Id_Tipo_Movimiento, Monto, Comentario, Fecha_Movimiento, Id_Proyecto, Id_Admin, Id_Trabajador, Id_Proveedor)
  //   VALUES (?, ?, ?, ?, ?, NOW(), ?, ?, ?, ?);
  // `;

  // db.query(
  //   queryInsert,
  //   [Id_Cliente, Id_Servicio, Id_Tipo_Movimiento, Monto, Comentario, Id_Proyecto, Id_Admin, Id_Trabajador, Id_Proveedor],


  const {
    Id_Cliente,
    Id_Servicio,
    Id_Tipo_Movimiento,
    Monto,
    Comentario,
    Id_Proyecto,
    Pago_Directo, // Asegúrate de que el frontend envíe este campo (true/false)
    Id_Admin,
    Id_Trabajador,
    Id_Proveedor
  } = req.body;

  // 👇 Modifica la consulta SQL para incluir Pago_Directo
  const queryInsert = `
    INSERT INTO movimientos_contables 
    (Id_Cliente, Id_Servicio, Id_Tipo_Movimiento, Monto, Comentario, Fecha_Movimiento, Id_Proyecto, Pago_Directo, Id_Admin, Id_Trabajador, Id_Proveedor)
    VALUES (?, ?, ?, ?, ?, NOW(), ?, ?, ?, ?, ?);
  `;

  // 👇 Añade Pago_Directo al array de parámetros
  db.query(
    queryInsert,
    [
      Id_Cliente,
      Id_Servicio,
      Id_Tipo_Movimiento,
      Monto,
      Comentario,
      Id_Proyecto,
      Pago_Directo, // Se envía como booleano (true/false)
      Id_Admin,
      Id_Trabajador,
      Id_Proveedor
    ],
    (err, result) => {
      if (err) {
        console.error('Error al insertar movimiento:', err);
        return res.status(500).json({ error: 'Error al insertar el movimiento' });
      }


    // Si es tipo 4: “extra” al presupuesto
      if (Id_Tipo_Movimiento === 4) {
        const queryExtra = `
          UPDATE proyectos
          SET Presupuesto = Presupuesto + ?
          WHERE Id_Proyecto = ?;
        `;
        return db.query(queryExtra, [Monto, Id_Proyecto], (err2) => {
          if (err2) {
            console.error('Error al actualizar presupuesto:', err2);
            return res.status(500).json({ error: 'Movimiento creado pero error al actualizar presupuesto' });
          }
          return res.status(200).json({ message: 'Movimiento creado y presupuesto aumentado', id: result.insertId });
        });
      }


      const montoAjustado = (Id_Tipo_Movimiento === 2) ? -Monto : Monto;

      // Si es tipo 2 o 3, actualizar banco
      if (Id_Tipo_Movimiento === 2 || Id_Tipo_Movimiento === 3) {
        const queryUpdateBanco = `
          UPDATE proyectos 
          SET dinero_banco = dinero_banco + ?
          WHERE Id_Proyecto = 2;
        `;

        db.query(queryUpdateBanco, [montoAjustado], (err2, result2) => {
          if (err2) {
            console.error('Error al actualizar dinero_banco en proyecto banco:', err2);
            return res.status(500).json({ error: 'Movimiento creado pero error al actualizar dinero_banco' });
          }

          // Si tipo 3, también actualizar adelantos
          if (Id_Tipo_Movimiento === 3) {
            const queryUpdateAdelantos = `
              UPDATE proyectos
              SET Adelantos = Adelantos + ?
              WHERE Id_Proyecto = ?;
            `;

            db.query(queryUpdateAdelantos, [Monto, Id_Proyecto], (err3, result3) => {
              if (err3) {
                console.error('Error al actualizar adelantos:', err3);
                return res.status(500).json({ error: 'Movimiento creado pero error al actualizar adelantos' });
              }

              return res.status(200).json({ message: 'Movimiento creado y ambos campos actualizados', id: result.insertId });
            });
          } else {
            // Solo se actualizó banco
            return res.status(200).json({ message: 'Movimiento creado y banco actualizado', id: result.insertId });
          }
        });
      } else {
        // Tipo de movimiento distinto, solo inserta movimiento
        return res.status(200).json({ message: 'Movimiento creado correctamente', id: result.insertId });
      }
    }
  );
});


// Obtener comentarios
app.post('/comentarios/obtener', (req, res) => {
  const { Id_Proyecto } = req.body;
  
  const query = `
    SELECT c.*
    FROM comentarios c

    WHERE c.Id_Proyecto = ?
    ORDER BY c.Fecha_Comentario DESC
  `;

  db.query(query, [Id_Proyecto], (err, results) => {
    if (err) {
      console.error('Error al obtener comentarios:', err);
      return res.status(500).json({ error: 'Error al obtener comentarios' });
    }
    res.json(results);
  });
});

// Crear comentario
app.post('/comentarios/crear', (req, res) => {
  const { Asunto, Comentario, Id_Proyecto } = req.body;

  const query = `
    INSERT INTO comentarios 
    (Asunto, Comentario, Id_Proyecto, Fecha_Comentario)
    VALUES (?, ?, ?, NOW())
  `;

  db.query(query, [Asunto, Comentario, Id_Proyecto], (err, result) => {
    if (err) {
      console.error('Error al crear comentario:', err);
      return res.status(500).json({ error: 'Error al crear comentario' });
    }
    res.status(201).json({ 
      Id_Comentario: result.insertId,
      message: 'Comentario creado exitosamente'
    });
  });
});

// Actualizar comentario
app.put('/comentarios/actualizar', (req, res) => {
  const { Id_Comentario, Asunto, Comentario } = req.body;

  const query = `
    UPDATE comentarios 
    SET Asunto = ?, Comentario = ?
    WHERE Id_Comentario = ?
  `;

  db.query(query, [Asunto, Comentario, Id_Comentario], (err, result) => {
    if (err) {
      console.error('Error al actualizar comentario:', err);
      return res.status(500).json({ error: 'Error al actualizar comentario' });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Comentario no encontrado' });
    }
    res.json({ message: 'Comentario actualizado exitosamente' });
  });
});

// Eliminar comentario
app.delete('/comentarios/eliminar', (req, res) => {
  const { Id_Comentario } = req.body;

  const query = `DELETE FROM comentarios WHERE Id_Comentario = ?`;

  db.query(query, [Id_Comentario], (err, result) => {
    if (err) {
      console.error('Error al eliminar comentario:', err);
      return res.status(500).json({ error: 'Error al eliminar comentario' });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Comentario no encontrado' });
    }
    res.json({ message: 'Comentario eliminado exitosamente' });
  });
});

// app.post('/crear_movimiento', (req, res) => {
//   const {
//     Id_Cliente,
//     Id_Servicio,
//     Id_Tipo_Movimiento,
//     Monto,
//     Comentario,
//     Id_Proyecto,
//     Id_Admin,
//     Id_Trabajador,
//     Id_Proveedor
//   } = req.body;

//   const queryInsert = `
//     INSERT INTO movimientos_contables 
//     (Id_Cliente, Id_Servicio, Id_Tipo_Movimiento, Monto, Comentario, Fecha_Movimiento, Id_Proyecto, Id_Admin, Id_Trabajador, Id_Proveedor)
//     VALUES (?, ?, ?, ?, ?, NOW(), ?, ?, ?, ?);
//   `;

//   db.query(
//     queryInsert,
//     [Id_Cliente, Id_Servicio, Id_Tipo_Movimiento, Monto, Comentario, Id_Proyecto, Id_Admin, Id_Trabajador, Id_Proveedor],
//     (err, result) => {
//       if (err) {
//         console.error('Error al insertar movimiento:', err);
//         return res.status(500).json({ error: 'Error al insertar el movimiento' });
//       }
 
//       if (Id_Tipo_Movimiento === 3 || Id_Tipo_Movimiento === 2) {
//         // Si es tipo 3 (adelanto) o tipo 1 (gasto),
//         // 1. Actualizar dinero_banco del proyecto 2 (banco)

// const montoAjustado = (Id_Tipo_Movimiento === 2) ? -Monto : Monto;

//         const queryUpdateBanco = `
//           UPDATE proyectos 
//           SET dinero_banco = dinero_banco + ?
//           WHERE Id_Proyecto = 2;
//         `;

//         db.query(queryUpdateBanco, [montoAjustado], (err2, result2) => {
//           if (err2) {
//             console.error('Error al actualizar dinero_banco en proyecto banco:', err2);
//             return res.status(500).json({ error: 'Movimiento creado pero error al actualizar dinero_banco' });
//           }

//           // 2. Actualizar adelantos del proyecto que invoca el movimiento
//           const queryUpdateAdelantos = `
//             UPDATE proyectos
//             SET Adelantos = Adelantos + ?
//             WHERE Id_Proyecto = ?;
//           `;

//           db.query(queryUpdateAdelantos, [Monto, Id_Proyecto], (err3, result3) => {
//             if (err3) {
//               console.error('Error al actualizar adelantos:', err3);
//               return res.status(500).json({ error: 'Movimiento creado pero error al actualizar adelantos' });
//             }

//             // Todo correcto
//             return res.status(200).json({ message: 'Movimiento creado y ambos campos actualizados', id: result.insertId });
//           });
//         });
//       } else {
//         return res.status(200).json({ message: 'Movimiento creado correctamente', id: result.insertId });
//       }
//     }
//   );
// });

//movimientos contables
// app.post('/crear_movimiento', (req, res) => {
//   const {
//     Id_Cliente,
//     Id_Servicio,
//     Id_Tipo_Movimiento,
//     Monto,
//     Comentario,
//     Id_Proyecto,
//     Id_Admin,
//     Id_Trabajador,
//     Id_Proveedor
//   } = req.body;

//   const queryInsert = `
//     INSERT INTO movimientos_contables 
//     (Id_Cliente, Id_Servicio, Id_Tipo_Movimiento, Monto, Comentario, Fecha_Movimiento, Id_Proyecto, Id_Admin, Id_Trabajador, Id_Proveedor)
//     VALUES (?, ?, ?, ?, ?, NOW(), ?, ?, ?, ?);
//   `;

//   db.query(
//     queryInsert,
//     [Id_Cliente, Id_Servicio, Id_Tipo_Movimiento, Monto, Comentario, Id_Proyecto, Id_Admin, Id_Trabajador, Id_Proveedor],
//     (err, result) => {
//       if (err) {
//         console.error('Error al insertar movimiento:', err);
//         return res.status(500).json({ error: 'Error al insertar el movimiento' });
//       }

//       // Si el movimiento es tipo 3, actualizamos el totalBanco sumando el monto
//     if (Id_Tipo_Movimiento === 3) {
//   const queryUpdateBanco = `
//     UPDATE proyectos 
//     SET dinero_banco = dinero_banco + ?
//     WHERE Id_Proyecto = 2;
//   `;

//   db.query(queryUpdateBanco, [Monto], (err2, result2) => {
//     if (err2) {
//       console.error('Error al actualizar totalBanco:', err2);
//       return res.status(500).json({ error: 'Movimiento creado pero error al actualizar banco' });
//     }

//     return res.status(200).json({ message: 'Movimiento creado y banco actualizado', id: result.insertId });
//   });
// }
// else {
//         return res.status(200).json({ message: 'Movimiento creado correctamente', id: result.insertId });
//       }
//     }
//   );
// });



// Iniciar servidor
app.listen(PORT,'0.0.0.0', () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
