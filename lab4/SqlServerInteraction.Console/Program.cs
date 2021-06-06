using SqlServerInteraction.Console.Dao;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SqlServerInteraction.Console
{
    class Program
    {
        static void Main(string[] args)
        {
            var factory = new DbWorkerFactory();
            var db = factory.Create();
            var console = new ConsoleWorker();

            var customers = db.SelectCustomers("Sao Paulo");
            console.WriteCustomers(customers);

            var id = db.InsertCategories();
            console.WriteCategoryID(id);

            db.UpdateCategories();

            db.DeleteCategories();

            db.InsertCategoriesBeginTransaction();

            System.Console.ReadLine();
        }
    }
}
