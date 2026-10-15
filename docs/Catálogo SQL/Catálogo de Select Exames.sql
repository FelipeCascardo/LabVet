SELECT * FROM labvet.animalgrupos;
SELECT * FROM labvet.analitos;
SELECT * FROM labvet.examecategorias;
SELECT * FROM labvet.exames;
SELECT * FROM labvet.exameanalitos;
SELECT * FROM labvet.modeloexames;
SELECT * FROM labvet.modeloexameanalitos;

SELECT * FROM labvet.exames
where idexame=20;


SELECT * FROM labvet.modeloexames
where nmmodelolaudo like 'HEM_CÃO_ FIB E RET 2026%';


SELECT * FROM labvet.modeloexameanalitos
where idmodeloexame = 188
order by nrexibicao ;